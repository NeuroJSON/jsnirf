JSNIRF: A lightweight and portable fNIRS data storage format
============================================================

- **Status of this document**: This document is current under development.
- **Copyright**: (C) Qianqian Fang (2019) <q.fang at neu.edu>
- **License**: Apache License, Version 2.0
- **Version**: 0.4
- **Abstract**:

> JSNIRF is a portable format for storage, interchange and processing
data generated from functional near-infrared spectroscopy - an emerging
neuroimaging technique. Built upon the JData and SNIRF specifications, 
a JSNIRF file has both a text-based interface using the JavaScript 
Object Notation (JSON) [RFC4627] format and a binary interface using 
the Universal Binary JSON (UBJSON) serialization format. It contains 
a compatibility layer to provide a 1-to-1 mapping to the existing HDF5 
based SNIRF files. A JSNIRF file can be directly parsed by most existing 
JSON and UBJSON parsers. Advanced features include optional hierarchical 
data storage, grouping, compression, integration with heterogeneous
scientific data enable by JData data serialization framework.


## Table of Content

- [Introduction](#introduction)
  * [Background](#background)
  * [JSNIRF specification overview](#jsnirf-specification-overview)
- [Grammar](#grammar)
- [JSNIRF Format](#jsnirf-format)
- [Data Orgnization and Grouping](#data-orgnization-and-grouping)
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
information including hemodynamic response of both oxy- and deoxy-hemoglobin 
concentrations, and is also capable of measuring absolute or variations of
tissue scattering and blood flow with superior temporal resolution. As a 
result, a steady growth of fNIRS based neuroimaging studies and systems has 
been observed over the past decade.

An fNIRS system typically involves an optical unit providing light sources
and detectors, a head-gear that couples the optical signals to the head surface,
and additional peripherical devices such as optode (source or detector) 3-D
position tracking, body physiology (heart rate, SpO2 or respiration,
blood pressure) monitoring, and the stimulus control. In some multi-modal
based fNIRS studies, anatomical scans using MRI/CT or functional montoring
using fMRI, electroencephalography (EEG) or magnetoencephalography (MEG) 
measurements may also need to be recorded.

Most commercially available fNIRS systems use vendor-specific format 
to store the measured data, making those difficult to be share among 
the community. The recent development of the Shared Near Infrared File 
Format Specification, or [SNIRF format](https://github.com/fnirs/snirf), 
specifically addresses this 
challenge and aims to provide a unified interface and format to share 
fNIRS measurements between systems across vendors.

The SNIRF specification uses HDF5 as the underlying file format to capture the 
essential data generated from various fNIRS devices or experiments.
In this document, we aim to develop a light-weight, portable, simple
interface to store SNIRF-compatible data, and suppements the HDF5 
based performance-oriented SNIRF files with additional features such 
as human-readability, built-in data compression, data grouping and 
easy integration with other neuroanatomical or functional measurements 
that can be potentially stored using 
[JData-based formats](https://github.com/fangq/jdata/blob/master/JData_specification.md).

Instead of using HDF5, JSNIRF utilizes [JavaScript Object Notation](http://json.org) 
(JSON) as the text-based storage format and [Universal Binary JSON (UBJSON)](http://ubjson.org) 
as the binary interface to gain smaller file sizes and faster processing speed. The 
[JData specification](https://github.com/fangq/jdata/blob/master/JData_specification.md)
provides the foundation for serializing complex hierarchical data using
JSON/UBJSON constructs. This permits us to define language- and library-neutral
fNIRS data representations using the simple and extensible constructs 
from JSON and UBJSON syntax.


### JSNIRF specification overview

In this specification, we define data containers that are capable of storing 
SNIRF-based fNIRS data structure, and allow one to convert SNIRF files to
JSON and UBJSON based files for easy parsing and integration.

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
 "jsnirf_keyword": [v1,v2,...,vn]
```
or
```
 "jsnirf_keyword": [
    [v11,v12,...,v1n],
    [v21,v22,...,v2n],
    ...
    [vm1,vm2,...,vmn]
  ]
```
or using the "annotated storage" format as
```
 "jsnirf_keyword": {
       "_ArrayType_": "typename",
       "_ArraySize_": [N1,N2,N3,...],
       "_ArrayData_": [v1,v2,v3,...]
  }
```
The direct storage format and the annotated storage format are equivalent. In the 
below sections, we use mostly the direct form to explain the data format, but
one shall also be able to store the data using the annotated format. We also note that
any valid JSON formatted data structure can be converted to a binary form using the
rules defined in the [UBJSON specification (Draft 12)](http://ubjson.org).


JSNIRF Format
------------------------

An HDF5 based SNIRF file shall be losslessly translated to a text or binary JSNIRF file
using the bellow table

|          SNIRF Data Container              |           JSNIRF Data Container                    |
|--------------------------------------------|----------------------------------------------------|
|` /                                        `|` "NIRSData" : {                                   `|
|` /formatVersion                           `|`      "formatVersion": "s",                       `|
|` /nirs[]                                  `|                                                    |
|`    .data[]                               `|`      "data": [                                   `|
|                                            |`         {                                        `|
|`       .dataTimeSeries                    `|`            "dataTimeSeries":      [[...]],       `|
|`       .time                              `|`            "time":                 [...],        `|
|`       .measurementList[]                 `|`            "measurementList": {                  `|
|`           .sourceIndex                   `|`                "sourceIndex":       <i>,         `|
|`           .detectorIndex                 `|`                "detectorIndex":     <i>,         `|
|`           .wavelengthIndex               `|`                "wavelengthIndex":   <i>,         `|
|`           .dataType                      `|`                "dataType":          <i>,         `|
|`           .dataTypeLabel                 `|`                "dataTypeLabel":     "s",         `|
|`           .dataTypeIndex                 `|`                "dataTypeIndex":     <i>,         `|
|`           .sourcePower                   `|`                "sourcePower":       <f>,         `|
|`           .detectorGain                  `|`                "detectorGain":      <f>,         `|
|`           .moduleIndex                   `|`                "moduleIndex":       <i>,         `|
|                                            |`         },                                       `|
|                                            |`         {...}                                    `|
|                                            |`      ],                                          `|
|`    .stim[]                               `|`      "stim": [                                   `|
|                                            |`         {                                        `|
|`        .name                             `|`             "name":                 "s",         `|
|`        .data                             `|`             "data":               [[...]],       `|
|                                            |`         },                                       `|
|                                            |`         {...}                                    `|
|                                            |`      ],                                          `|
|`    .probe                                `|`      "probe": {                                  `|
|`        .wavelengths                      `|`             "wavelengths":         [...],        `|
|`        .wavelengthsEmission              `|`             "wavelengthsEmission": [...],        `|
|`        .sourcePos                        `|`             "sourcePos":          [[...]],       `|
|`        .sourcePos3D                      `|`             "sourcePos3D":        [[...]],       `|
|`        .detectorPos                      `|`             "detectorPos":        [[...]],       `|
|`        .detectorPos3D                    `|`             "detectorPos3D":      [[...]],       `|
|`        .frequencies                      `|`             "frequencies":         [...],        `|
|`        .timeDelays                       `|`             "timeDelays":          [...],        `|
|`        .timeDelayWidths                  `|`             "timeDelayWidths":     [...],        `|
|`        .momentOrders                     `|`             "momentOrders":        [...],        `|
|`        .correlationTimeDelays            `|`             "correlationTimeDelays":[...],       `|
|`        .correlationTimeDelayWidths       `|`             "correlationTimeDelayWidths": [...], `|
|`        .sourceLabels[]                   `|`             "sourceLabels":        [...],        `|
|`        .detectorLabels[]                 `|`             "detectorLabels":      [...],        `|
|`        .landmarkPos                      `|`             "landmarkPos":        [[...]],       `|
|`        .landmarkPos3D                    `|`             "landmarkPos3D":      [[...]],       `|
|`        .landmarkLabels[]                 `|`             "landmarkLabels":      [...],        `|
|`        .useLocalIndex                    `|`             "useLocalIndex":        <i>          `|
|                                            |`      },                                          `|
|`    .metaDataTags[]                       `|`      "metaDataTags": [                           `|
|                                            |`         {                                        `|
|`        'ManufacturerName'                `|`             "ManufacturerName":     "s",         `|
|`        'Model'                           `|`             "Model":                "s",         `|
|`        'SubjectID'                       `|`             "SubjectID":            "s",         `|
|`        'MeasurementDate'                 `|`             "MeasurementDate":      "s",         `|
|`        'MeasurementTime'                 `|`             "MeasurementTime":      "s",         `|
|`        'SpatialUnit'                     `|`             "SpatialUnit":          "s",         `|
|`        'SubjectName'                     `|`             "SubjectName":          "s",         `|
|`        'StudyID'                         `|`             "StudyID":              "s",         `|
|                                            |`         },                                       `|
|                                            |`         {...}                                    `|
|                                            |`      ],                                          `|
|`    .aux[]                                `|`      "aux": [                                    `|
|                                            |`         {                                        `|
|`        .name                             `|`          "name":                    "s",         `|
|`        .dataTimeSeries                   `|`          "dataTimeSeries":        [[...]],       `|
|`        .time                             `|`          "time":                   [...],        `|
|`        .timeOffset                       `|`          "timeOffset":             [...],        `|
|                                            |`         },                                       `|
|                                            |`         {...}                                    `|
|                                            |`      ]                                           `|
|                                            |` }                                                `|


In the above table, the notations are explained below

* `<i>` represents an integer value (signed integer of 8, 16, 32 or 64bit)
* `<f>` represents an numerical value (including integers, 32bit and 64bit floating point numbers)
* `"s"` represents a UTF-8 encoded string of arbitrary length
* `[...]` represents a 1-D vector
* `[[...]]` represents a 2-D array
* `{...}` represents (optional) additional elements, user-defined data or future extensions
* `<i>|"s"` represents alternative forms, in this example, the field can be either an integer or a string

To convert a SNIRF file to the JSNIRF structure, the storage type in the
target subfields must have equal or larger byte length to store the original SNIRF 
data without losing accuracy; in the case of a string value, the new string must have the same 
length or longer to store the entire original string value.

If the SNIRF data field contains an array, the converted JSNIRF subfield shall also
contain an array object sorted in the same order.

The order of the JSNIRF subfields is not required.

A reversed direction mapping, i.e. from JSNIRF to SNIRF, is not guaranteed to be lossless.


Data Orgnization and Grouping
------------------------

To facilitate the organization of multiple neuroimaging datasets, JSNIRF supports **optional**
data grouping mechanisms similar to those defined in the JData specification. 

In a JSNIRF document, one can use **"NIRSGroup"** and **"NIRSObject"** to organize
datasets in a hierarchical form. They are equivalent to the **`"_DataGroup_"`** and **`"_DataSet_"`**
constructs, respectively, as defined in the JData specification, but are specifically 
applicable to neuroimaging data. The format of `"NIRSGroup"` and `"NIRSObject"` are identical 
to JData data grouping tags, i.e, they can be either an array or structure, with an 
optional unique name (within the current document) via `"NIRSGroup(unique name)"`
and `"NIRSObject(unique name)"`

For example, the below JSNIRF snippet defines two data groups with each containing 
multiple NIRS datasets.  Here we also show examples on storing multiple `NIRSHeader`
and `NIRSData` records under a common parent, as well as the use of `"_DataLink_"` defined
in the JData specification for flexible data referencing.

```
{
    "NIRSGroup(studyname1)": {
           "NIRSData(subj1)": {
              ...
           },
           "NIRSData(subj2)": {
              ...
           },
           "NIRSObject(subj3)": {
               "NIRSData(visit1)":{ ... },
               "NIRSData(visit2)":[ ... ]
           }
    },
    "NIRSGroup(studyname2)": {
           "NIRSObject(subj1)": {
               "NIRSHeader":{ ... },
               "NIRSData":[ ... ]
           },
           "NIRSObject(subj2)": {
               "NIRSData":[ ... ]
           },
           "NIRSObject(subj3)": {
               "_DataLink_": "file:///space/test/jsnirf/study2subj3.jnii"
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

In summary, this specification defines 

By using JSON/UBJSON compatible JData constructs, JSNIRF provides a highly portable, versatile
and extensible framework to store a large variety of neuroanatomical and functional image 
data. Both text and binary formats are readable with self-explanatory keywords. The broad 
availability of JSON and UBJSON parsers, along with the simple underlying syntax, allows one
to easily share, parse and process such data files without imposing extensive programming
overhead. The flexible data organization and referencing mechanisms offered by the underlying 
JData specification make it possible to record and share large scale complex neuroimaging 
datasets among researchers, clinicians and data scientists.
