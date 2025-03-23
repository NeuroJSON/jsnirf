JSNIRF: A lightweight and portable fNIRS data storage format
============================================================

- **Status of this document**: This document is current under development.
- **Copyright**: (C) 2019-2025 Qianqian Fang <q.fang at neu.edu>
- **License**: Apache License, Version 2.0
- **Version**: V1 (Draft-2)
- **Abstract**:

> JSNIRF is a portable format for storage, interchange and processing
data generated from functional near-infrared spectroscopy, or fNIRS - an emerging
functional neuroimaging technique. Built upon the JData and SNIRF specifications, 
a JSNIRF file has both a text-based interface using the JavaScript 
Object Notation (JSON) [RFC4627] format and a binary interface using 
the Universal Binary JSON (UBJSON) serialization format. It contains 
a compatibility layer to provide a 1-to-1 mapping to the existing HDF5 
based SNIRF files. A JSNIRF file can be directly parsed by most existing 
JSON and UBJSON parsers. Advanced features include optional hierarchical 
data storage, grouping, compression, integration with heterogeneous
scientific data enabled by JData data serialization framework.


## Table of Content

- [Introduction](#introduction)
  * [Background](#background)
  * [JSNIRF specification overview](#jsnirf-specification-overview)
- [Grammar](#grammar)
- [JSNIRF Format](#jsnirf-format)
- [Data Organization and Grouping](#data-organization-and-grouping)
- [Recommended File Specifiers](#recommended-file-specifiers)
- [Summary](#summary)


Introduction
------------

### Background


Functional near-infrared spectroscopy, or fNIRS, is an emerging neuroimaging
technique. It is capable of capturing brain activations via the measurement
of hemodynamic responses using non-invasive low-power near-infrared light,
thus, having the advantages of being safe, portable, versatile and low-cost.
In comparison to functional MRI (fMIR), fNIRS not only provides rich functional
information including hemodynamic responses of both oxy- and deoxy-hemoglobin 
concentrations, but also is capable of quantifying absolute values or variations of
tissue scattering and blood flow with superior temporal resolution. As a 
result, a steady growth of fNIRS based neuroimaging studies and systems has 
been observed over the past decade.

An fNIRS system typically involves an optical unit providing light sources
and detectors, a head-gear that couples the optical signals to the head surface,
and additional peripheral devices such as optode (optical source or detector) 3-D
position tracking, body physiology (heart rate, SpO2 or respiration,
blood pressure) monitoring, and stimulus control. In some multi-modal
based fNIRS studies, anatomical scans using MRI/CT or functional monitoring
using fMRI, electroencephalography (EEG) or magnetoencephalography (MEG) 
may also need to be recorded.

Most commercially available fNIRS systems use vendor-specific format 
to store the measured data, making the data difficult to be share among 
the community. The recent development of the Shared Near Infrared File 
Format Specification, or [SNIRF format](https://github.com/fNIRS/snirf/), 
specifically addresses this challenge and aims to provide a unified 
interface and format to store and share fNIRS measurements between 
systems across vendors.

The [SNIRF specification](https://github.com/fNIRS/snirf/) uses 
[HDF5](https://www.hdfgroup.org/solutions/hdf5/) as the underlying file format to capture the 
essential data generated from various fNIRS devices or experiments.
In this document, we aim to develop a light-weight, portable, simple
interface to store SNIRF-compatible data, and supplements the HDF5 
based performance-oriented SNIRF files with additional features such 
as human-readability, extensible data annotation, data grouping and 
easy integration with other neuroanatomical or functional measurements 
that can be potentially stored using [JData-based formats](https://github.com/NeuroJSON/jdata)

Instead of using HDF5, JSNIRF utilizes [JavaScript Object Notation](https://json.org) 
(JSON) as the text-based storage format and [Binary JData](https://github.com/NeuroJSON/bjdata)
derived based on [Universal Binary JSON (UBJSON)](https://ubjson.org),
as the binary interface to gain smaller file sizes and faster processing speed. The 
[JData specification](https://github.com/NeuroJSON/jdata/blob/master/JData_specification.md)
provides the foundation for serializing complex hierarchical data using
JSON/UBJSON constructs. This permits us to define language- and library-neutral
fNIRS data representations using the simple and extensible constructs 
using the JSON and UBJSON syntax. The use of JSON/UBJSON based JSNIRF data
files also extends reading and writing SNIRF in environments where the HDF5 format
is not supported, such as MATLAB older than R2011a and GNU Octave.


### JSNIRF specification overview

In this specification, we define data containers that are capable of storing 
SNIRF-based fNIRS data structure, and allow one to convert SNIRF files to
JSON and UBJSON based files for easy sharing, parsing and integration.

The purpose of this document is to

- define a 1-to-1 mapping between the existing SNRIF data structures
  to a JSON/UBJSON-based flexible data structure to allow lossless conversion
  from HDF5 data to JSON/UBJSON data
- demonstrate a set of flexible mechanisms to extend the capability of the 
  format to accommodate additional physiological, anatomical and multi-modal data

In the following sections, we will clarify the basic JSNIRF grammar and define 
JSNIRF data containers. The additional features and extension mechanisms are 
also discussed and exemplified.



Grammar
------------------------

All JSNIRF files are JData specification compliant. The same as JData, it has
both a text format based on JSON serialization and a binary format based on 
the UBJSON serialization scheme. The two forms can be converted from one
to another.

Briefly, the text-based JSNIRF is a valid JSON file with the extension to 
support concatenated JSON objects; the binary-format JSNIRF is a valid UBJSON 
file with the extended syntax to support N-D array. Please refer to the JData 
specification for the definitions.

Many of the SNIRF data subfields have a value of 1-D vector or 2-D arrays.
According to the JData specification, N-D array has two equivalent and 
interchangeable storage forms - the direct storage format and the annotated 
storage format. 

For example, one can store a 1-D or 2-D array using the direct storage format as
```
 "jsnirf_keyword_1d": [v1,v2,...,vn]
```
or
```
 "jsnirf_keyword_2d": [
    [v11,v12,...,v1n],
    [v21,v22,...,v2n],
    ...
    [vm1,vm2,...,vmn]
  ]
```
or using the "annotated storage" format as
```
 "jsnirf_keyword_nd": {
       "_ArrayType_": "typename",
       "_ArraySize_": [N1,N2,N3,...],
       "_ArrayData_": [v1,v2,v3,...]
  }
```
The direct storage format and the annotated storage format are equivalent. In the 
below sections, we use mostly the direct form to explain the data format, but
one shall also be able to store the data using the annotated format. We also note that
any valid JSON formatted data structure can be converted to a binary form using the
rules defined in the [Binary JData](https://github.com/NeuroJSON/bjdata) derived from
the [UBJSON specification (Draft 12)](https://ubjson.org).


JSNIRF Format
------------------------

An HDF5 based SNIRF file shall be losslessly translated to a text or binary JSNIRF file
using the bellow mapping table

***Table 1. A mapping table for HDF5 SNIRF file to JSNIRF SNIRFData structure***

|          SNIRF Data Container         |     JSNIRF Data Container (in JSON format)    |Required|
|---------------------------------------|-----------------------------------------------|--------|
| `/nirs{}`                             | `"SNIRFData" : [`                             |        |
|                                       |   `{`                                         |        |
|  `formatVersion`                      |     `"formatVersion": "s",`                   |   *    |
|                                       |     `"nirs": {`                               |   *    |
|     `metaDataTags`                    |        `"metaDataTags": {`                    |   *    |
|        `"SubjectID"`                  |             `"SubjectID":            "s",`    |   *    |
|        `"MeasurementDate"`            |             `"MeasurementDate":      "s",`    |   *    |
|        `"MeasurementTime"`            |             `"MeasurementTime":      "s",`    |   *    |
|        `"LengthUnit"`                 |             `"LengthUnit":           "s",`    |   *    |
|        `"TimeUnit"`                   |             `"TimeUnit":             "s",`    |   *    |
|        `"FrequencyUnit"`              |             `"FrequencyUnit":        "s",`    |   *    |
|        `"SubjectName"`                |             `"SubjectName":          "s",`    |        |
|        `"StudyID"`                    |             `"StudyID":              "s",`    |        |
|        `"ManufacturerName"`           |             `"ManufacturerName":     "s",`    |        |
|        `"Model"`                      |             `"Model":                "s",`    |        |
|         ...                           |              ...                              |        |
|                                       |       `},`                                    |        |
|     `data{}`                          |       `"data": [`                             |   *    |
|                                       |           `{`                                 |        |
|        `dataTimeSeries`               |            `"dataTimeSeries":    [[<f>,...]],`|   *    |
|        `time`                         |            `"time":               [<f>,...],` |   *    |
|        `measurementLists{.}`          |            `"measurementLists": {.}`          |   *^1  |
|        `measurementList{}`            |            `"measurementList": {`             |   *^1  |
|            `sourceIndex`              |                `"sourceIndex":    [<i>,...],` |   *    |
|            `detectorIndex`            |                `"detectorIndex":  [<i>,...],` |   *    |
|            `wavelengthIndex`          |                `"wavelengthIndex":[<i>,...],` |   *    |
|            `wavelengthActual`         |                `"wavelengthActual":[<f>,...],`|        |
|            `wavelengthEmissionActual` |                `"wavelengthEmissionActual":[<f>,...],` |        |
|            `dataType`                 |                `"dataType":       [<i>,...],` |   *    |
|            `dataUnit`                 |                `"dataUnit":       ["s",...],` |        |
|            `dataTypeLabel`            |                `"dataTypeLabel":  ["s",...],` |        |
|            `dataTypeIndex`            |                `"dataTypeIndex":  [<i>,...],` |   *    |
|            `sourcePower`              |                `"sourcePower":    [<f>,...],` |        |
|            `detectorGain`             |                `"detectorGain":   [<f>,...],` |        |
|                                       |            `}`                                |        |
|                                       |           `},`                                |        |
|                                       |           `{...}`                             |        |
|                                       |       `],`                                    |        |
|     `stim{}`                          |       `"stim": [`                             |        |
|                                       |           `{`                                 |        |
|         `name`                        |             `"name":               "s",`      |   +    |
|         `data`                        |             `"data":             [[<f>,...]],`|   +    |
|         `dataLabels`                  |             `"dataLabels":       [["s",...]],`|   +    |
|                                       |           `},`                                |        |
|                                       |           `{...}`                             |        |
|                                       |       `],`                                    |        |
|     `probe`                           |       `"probe": {`                            |   *    |
|         `wavelengths`                 |             `"wavelengths":       [<f>,...],` |   *    |
|         `wavelengthsEmission`         |             `"wavelengthsEmission":[<f>,...],`|        |
|         `sourcePos2D`                 |             `"sourcePos2D":      [[<f>,...]],`|   *1   |
|         `sourcePos3D`                 |             `"sourcePos3D":      [[<f>,...]],`|   *1   |
|         `detectorPos2D`               |             `"detectorPos2D":    [[<f>,...]],`|   *2   |
|         `detectorPos3D`               |             `"detectorPos3D":    [[<f>,...]],`|   *2   |
|         `frequencies`                 |             `"frequencies":       [<f>,...],` |        |
|         `timeDelays`                  |             `"timeDelays":        [<f>,...],` |        |
|         `timeDelayWidths`             |             `"timeDelayWidths":   [<f>,...],` |        |
|         `momentOrders`                |             `"momentOrders":      [<f>,...],` |        |
|         `correlationTimeDelays`       |             `"correlationTimeDelays":[<f>,...],`   |        |
|         `correlationTimeDelayWidths`  |             `"correlationTimeDelayWidths":[<f>,...],`|        |
|         `sourceLabels`                |             `"sourceLabels":      ["s",...],` |        |
|         `detectorLabels`              |             `"detectorLabels":    ["s",...],` |        |
|         `landmarkPos2D`               |             `"landmarkPos2D":    [[<f>,...]],`|        |
|         `landmarkPos3D`               |             `"landmarkPos3D":    [[<f>,...]],`|        |
|         `landmarkLabels`              |             `"landmarkLabels":    ["s",...],` |        |
|         `coordinateSystem`            |             `"coordinateSystem":   "s",`      |        |
|         `coordinateSystemDescription` |             `"coordinateSystemDescription":"s",`|        |
|                                       |       `},`                                    |        |
|     `aux{}`                           |       `"aux": [`                              |        |
|                                       |          `{`                                  |        |
|         `name`                        |            `"name":                "s",`      |   +    |
|         `dataTimeSeries`              |            `"dataTimeSeries":    [[<f>,...]],`|   +    |
|         `dataUnit`                    |            `"dataUnit":            "s",`      |        |
|         `time`                        |            `"time":               [<f>,...],` |   +    |
|         `timeOffset`                  |            `"timeOffset":         [<f>,...],` |        |
|                                       |          `},`                                 |        |
|                                       |          `{...}`                              |        |
|                                       |       `]`                                     |        |
|                                       |     `} `                                      |        |
|                                       |   `}`,                                        |        |
|                                       |   `{...}`                                     |        |
|                                       | `]`                                           |        |

In the above table, the notations are explained below

* `{}` represents an HDF5 indexed-group which may contain one or multiple sub-groups
* `<i>` represents an integer value (signed integer of 8, 16, 32 or 64bit)
* `<f>` represents an numerical value (including integers, 32bit and 64bit floating point numbers)
* `"s"` represents a UTF-8 encoded string of arbitrary length
* `[...]` represents a 1-D (row or column) vector, can be empty
* `[[...]]` represents a 2-D array, can be empty
* `{...}` represents (optional) additional elements, user-defined data or future extensions
* `...` (optional) additional elements similar to the previous element
* `*` in the last column indicates a required subfield
* `+` in the last column indicates a required subfield if the optional parent object is included
* `^n` in the last column indicates that exactly one of the subfields in the subgroup identified by `n` is required, and no more than one should be present.
* `*n` in the last column indicates that at least one of the subfields in the subgroup identified by `n` is required

To convert a SNIRF file to the JSNIRF structure, the storage type in the
target subfields must have equal or larger byte length to store the original SNIRF 
data without losing accuracy; in the case of a string value, the new string must have the same 
length or longer to store the entire original string value.

The requirements for the dimensions of the 1-D and 2-D array subfields are specified
in the SNIRF specification.

The order of the subfields in each element of the `SNIRFData` object is not required. However, 
it is generally recommended that the `formatVersion` and `metaDataTags` appear before
other subfields.

A reversed direction mapping, i.e. from JSNIRF to SNIRF, is not guaranteed to be lossless.

### SNIRFData (mapped from SNIRF `/nirs{}`)

The `SNIRFData` container is equivalent to the `/nirs{}` object in a SNIRF file. It is a JSON
array object with 1 or multiple elements - the first element maps to `/nirs` or `/nirs1`, the
2nd element maps to `/nirs2`, and so on. When it contains only a single element, the `SNIRData`
can be the value of the first element, without needing the array container.

### formatVersion (mapped from SNIRF `formatVersion`)

The `formatVersion` object, originally stored in the root level in SNIRF, is now a subfield 
repeated in each of the element in the `SNIRFData` object. This way, the total element count 
of the `SNIRFData` container equals to the total sub-group count of the `/nirs{}` object.

### measurementList (mapped from SNIRF `/nirs{}/data{}/measurementList{}`)

In the SNIRF format, the `measurementList` is defined as an 
[array of structures (AoS)](https://github.com/NeuroJSON/jdata/blob/master/JData_specification.md#tables), where
`measurementList1` defines the source/detector settings for the 1st column of `data{}`. In 
JSNIRF, we define `measurementList` as a 
[structure of arrays (SoA)](https://github.com/NeuroJSON/jdata/blob/master/JData_specification.md#tables) 
where each sub-field is a 1-D vector, with the length matching the total count of 
the SNIRF `measurementList` elements.

### measurementLists (mapped from SNIRF `/nirs{}/data{}/measurementLists{}`)

Starting in SNIRF format v1.2, a new container, `measurementLists`, is introduced as an alternative to 
the less disk-efficient `measurementList` container. Instead of storing array of structures (AoS),
`measurementLists` stores structure of arrays (SoA), greatly reducing the storage overhead.

Because JSNIRF's `measurementList` container is already required to use the array of structures (AoS)
by default, the `measurementLists` is simply an alias to `measurementList` in JSNIRF. One and 
only one of the two containers should present in a single `SNIRFData` element.


Data Organization and Grouping
------------------------

To facilitate the organization of multiple neuroimaging datasets, JSNIRF supports **optional**
data grouping mechanisms similar to those defined in the JData specification. 

In a JSNIRF document, one can use **"NIRSGroup"** and **"NIRSObject"** to organize
datasets in a hierarchical form. They are equivalent to the **`"_DataGroup_"`** and **`"_DataSet_"`**
constructs, respectively, as defined in the JData specification, but are specifically 
applicable to NIRS and fNIRS data. The format of `"NIRSGroup"` and `"NIRSObject"` are identical 
to JData data grouping tags, i.e, they can be either an array or structure, with an 
optional unique name (within the current document) via `"NIRSGroup(unique name)"`
and `"NIRSObject(unique name)"`

For example, the below JSNIRF snippet defines two data groups with each containing 
multiple NIRS datasets.  Here we also show examples on storing multiple `SNIRFData` 
records under a common parent, as well as the use of `"_DataLink_"` defined
in the JData specification for flexible data referencing.

```
{
    "NIRSGroup(studyname1)": {
           "SNIRFData(sub-001)": {
              ...
           },
           "SNIRFData(sub-002)": {
              ...
           },
           "NIRSObject(sub-003)": {
               "SNIRFData(sub-003_sess1)":[ ... ],
               "SNIRFData(sub-003_sess2)":[ ... ]
           }
    },
    "NIRSGroup(studyname2)": {
           "sub-001": {
               "NIRSObject": {
                   "SNIRFData":[ ... ]
               }
           },
           "sub-002": {
               "NIRSObject": {
                   "_DataInfo_": {
                       "Operator": "Ted",
                       "HasMRI": true,
                       "HasEEG": true,
                       "Comment": "a multi-modal study"
                   },
                   "SNIRFData": [ ... ]
               },
               "NIFTIObject": {
                    NIFTIHeader: { ... },
                    NIFTIData: { ... }
               }
           },
           "sub-003": {
               "NIRSObject": {
                   "_DataLink_": "file:///space/test/jsnirf/study2subj3.bnirs"
               }
           }
     }
}
```

Recommended File Specifiers
------------------------------

For the text-based JSNIRF file, the recommended file suffix is **`".jnirs"`**; for 
the binary JSNIRF file, the recommended file suffix is **`".bnirs"`**.

The MIME type for the text-based JSNIRF document is 
**`"application/jsnirf-text"`**; that for the binary JSNIRF document is 
**`"application/jsnirf-binary"`**


Summary
----------

In summary, this specification defines a 1-to-1 mapping between the HDF5-based SNIRF storage
format to JSON/UBJSON based JSNIRF format. Any previously generated SNIRF file can be 100% 
mapped to a JSNIRF document without losing any information. However, JSNIRF adds readability, 
portability with lightweight and widely available parsers. It also allows one to easily 
combine NIRS measurements with other experimental data stored in JData-compliant 
formats, such as [JNIfTI](https://github.com/NeuroJSON/jnifti) or [JMesh](https://github.com/NeuroJSON/jmesh), 
especially in a multi-modal imaging study.

Compared to HDF5, JSON and UBJSON is significantly simpler when encoding and decoding 
unstructured data, such as the data structure defined in a SNIRF file. 
The broad availability of JSON and UBJSON parsers, along with the simple underlying syntax, allows one
to easily share, parse and process such data files without imposing extensive programming
overhead. The flexible data organization and referencing mechanisms offered by the underlying 
JData specification make it possible to record and share large scale complex neuroimaging 
datasets among researchers, clinicians and data scientists.
