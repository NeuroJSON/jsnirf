function data=loadsnirf(fname,varargin)
%
%    data=loadsnirf(fname)
%       or
%    jnirs=loadsnirf(fname, 'Param1',value1, 'Param2',value2,...)
%
%    Load an HDF5 based SNIRF file, and optionally convert it to a JSON 
%    file based on the JSNIRF specification:
%    https://github.com/fangq/jsnirf
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        fname: the input snirf data file name (HDF5 based)
%
%    output:
%        data: a MATLAB structure with the grouped data fields
%
%    example:
%        data=loadsnirf('test.snirf');
%
%    this file is part of JSNIRF specification: https://github.com/fangq/jsnirf
%
%    License: Apache 2.0, see https://github.com/fangq/jsnirf for details
%

if(nargin==0 || ~ischar(fname))
    error('you must provide a file name');
end

opt=varargin2struct(varargin{:});
data=loadh5(fname);
data=snirfdecode(data,'snirf');

outfile=jsonopt('FileName','',opt);
if(~isempty(outfile))
    if(regexp(outfile,'\.[Bb][Nn][Ii][Rr][Ss]$'))
        saveubjson('SNIRDData',data,'FileName',outfile,opt);
    elseif(~isempty(regexp(outfile,'\.[Jj][Nn][Ii][Rr][Ss]$', 'once'))|| ~isempty(regexp(outfile,'\.[Jj][Ss][Oo][Nn]$', 'once')))
        savejson('SNIRDData',data,'FileName',outfile,opt);
    elseif(regexp(outfile,'\.[Mm][Aa][Tt]$'))
        save(outfile,'data');
    else
        error('only support .jnirs,.bnirs and .mat files');
    end
end
