function jsn=jsnirfcreate(varargin)
%
%    jsn=jsnirfcreate
%       or
%    jsn=jsnirfcreate('Param1',value1, 'Param2',value2,...)
%
%    Load a text (.jnirs or .json) or binary (.bnirs) based JSNIRF 
%    file defined in the JSNIRF specification: https://github.com/fangq/jsnirf
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        inputfile: the output file name to the JSNIRF or SNIRF file
%                *.snirf for binary JSNIRF file
%                *.jnirs for text JSNIRF file
%                *.bnirs  for NIFTI-1/2 files
%        options: (optional) if loading from a .bnii file, please see the options for
%               loadubjson.m (part of JSONLab); if loading from a .jnirs, please see the 
%               supported options for loadjson.m (part of JSONLab).
%
%    output:
%        jnirs: a structure (array) or cell (array). The data structure can
%            be completely generic or auxilary data without any JSNIRF
%            constructs. However, if a JSNIRF object is included, it shall
%            contain the below subfields (can appear within any depth of the
%            structure)
%
%    example:
%        newjnirs=loadjsnirf('magic10.jnirs');
%
%    this file is part of JSNIRF specification: https://github.com/fangq/jsnirf
%
%    License: Apache 2.0, see https://github.com/fangq/jsnirf for details
%

if(nargin<1)
    error('you must provide data and output file name');
end

if(~exist('savejson','file'))
    error('you must first install JSONLab from http://github.com/fangq/jsonlab/');
end

if(regexp(filename,'\.snirf$'))
    jnirs=loadsnirf(filename);
elseif(regexp(filename,'\.jnirs$'))
    jnirs=loadjson(filename,varargin{:});
elseif(regexp(filename,'\.bnii$'))
    jnirs=loadubjson(filename,varargin{:});
else
    error('file suffix must be .jnirs for text JSNIRF, .bnii for binary JSNIRF or .nii for NIFTI-1/2 files');
end
