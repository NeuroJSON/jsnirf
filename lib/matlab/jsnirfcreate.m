function jsn=jsnirfcreate(varargin)
%
%    jsn=jsnirfcreate(option)
%       or
%    jsn=jsnirfcreate('snirf')
%    jsn=jsnirfcreate('Param1',value1, 'Param2',value2,...)
%
%    Load a text (.jnirs or .json) or binary (.bnirs) based JSNIRF 
%    file defined in the JSNIRF specification: https://github.com/fangq/jsnirf
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        option (optional): option can be empty. If it is a string with a
%             value 'snirf', this creates a default SNIRF data structure;
%             otherwise, a JSNIRF data structure is created.
%             if option is a list of name/value pairs, one can specify
%             additional subfields to be stored under the root object.
%
%    output:
%        jsn: a default SNIRF or JSNIRF data structure.
%
%    example:
%        jsn=jsnirfcreate('data',mydata,'aux',myauxdata,'comment','test');
%
%    this file is part of JSNIRF specification: https://github.com/fangq/jsnirf
%
%    License: Apache 2.0, see https://github.com/fangq/jsnirf for details
%

defaultmeta=struct('SubjectID','default','MeasurementDate','unknown',...
                'MeasurementTime','unknown','LengthUnit','mm');
defaultsrcmap=struct('sourceIndex',[],'detectorIndex',[],...
              'wavelengthIndex',[],'dataType',1,'dataTypeIndex',1); 
defaultdata=struct('dataTimeSeries',[],'time',[],'measurementList',defaultsrcmap);
defaultaux=struct('name','','dataTimeSeries',[],'time',[],'timeOffset',0);
defaultstim=struct('name','','data',[]);
defaultprobe=struct('wavelengths',[],'sourcePos',[],'detectorPos',[]);

nirsdata=struct('metaDataTags',defaultmeta,...
                'data',defaultdata,...
                'aux',defaultaux,...
                'stim',defaultstim,...
                'probe',defaultprobe);

if(nargin>1 && bitand(nargin,2)==0)
    for i=1:nargin*0.5
        nirsdata.(varargin{2*i-1})=varargin{2*i};
    end
end

jsn=struct();

if(nargin==1 && strcmpi(varargin{1},'snirf'))
    jsn=struct('formatVersion',1,'nirs', nirsdata);
else
    nirsdata.formatVersion=1;
    jsn=struct('SNIRFData', nirsdata);
end