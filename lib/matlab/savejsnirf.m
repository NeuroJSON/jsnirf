function data=savejsnirf(jnirs, filename, varargin)
%
%    savejsnirf(jnirs, outputfile)
%       or
%    savejsnirf(jnirs, outputfile, 'Param1',value1, 'Param2',value2,...)
%
%    Save an in-memory JSNIRF structure into a JSNIRF file with format
%    defined in JSNIRF specification: https://github.com/fangq/jsnirf
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        jnirs: a structure (array) or cell (array). The data structure can
%            be completely generic or auxilary data without any JSNIRF
%            constructs. However, if a JSNIRF object is included, it shall
%            contain the below subfields (can appear within any depth of the
%            structure)
%                jnirs.SNIRFData - the main image data array
%        outputfile: the output file name to the JSNIRF file 
%                *.bnii for binary JSNIRF file
%                *.jnirs for text JSNIRF file
%        options: (optional) if saving to a .bnirs file, please see the options for
%               saveubjson.m (part of JSONLab); if saving to .jnirs, please see the 
%               supported options for savejson.m (part of JSONLab).
%
%    example:
%        jnirs=jsnirfcreate('aux',struct('name','pO2','dataTimeSeries',1:10,'time',1:10));
%        savejsnirf(jnirs, 'test.jnirs');
%        savejsnirf(jnirs, 'test.bnirs','compression','zlib');
%
%    this file is part of JSNIRF specification: https://github.com/fangq/jsnirf
%
%    License: Apache 2.0, see https://github.com/fangq/jsnirf for details
%

if(nargin<2)
    error('you must provide data and output file name');
end

if(~exist('savejson','file'))
    error('you must first install JSONLab from http://github.com/fangq/jsonlab/');
end

data='';

if(regexp(filename,'\.jnirs$'))
    data=savejson('',jnirs,filename,varargin{:});
elseif(regexp(filename,'\.bnirs$'))
    data=saveubjson('',jnirs,filename,varargin{:});
else
    error('file suffix must be .jnirs for text JSNIRF or .bnirs for binary JSNIRF');
end
