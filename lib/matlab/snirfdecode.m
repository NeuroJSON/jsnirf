function data=snirfdecode(root)
%
%    data=snirfdecode(root)
%
%    Processing an HDF5 based SNIRF data and group indexed datasets into a
%    cell array
%
%    author: Qianqian Fang (q.fang <at> neu.edu)
%
%    input:
%        root: the input snirf data structure (loaded from loadsnirf.m)
%
%    output:
%        data: a simplified matlab structure
%
%    example:
%        data=loadsnirf('test.snirf');
%
%    this file is part of JSNIRF specification: https://github.com/fangq/jsnirf
%
%    License: Apache 2.0, see https://github.com/fangq/jsnirf for details
%

data=struct;
if(isstruct(root))
    names=fieldnames(root);
    newnames=struct();

    for i=1:length(names)
        item=regexp(names{i},'^(\w+)(\d+)$','tokens');
        if(~isempty(item) && str2num(item{1}{2})~=0)
            if(~isfield(newnames,item{1}{1}))
                newnames.(item{1}{1})=[str2num(item{1}{2})];
            else
                newnames.(item{1}{1})=[newnames.(item{1}{1}), str2num(item{1}{2})];
            end
        else
            if(isstruct(root.(names{i})))
                data.(names{i})=snirfdecode(root.(names{i}));
            else
                data.(names{i})=root.(names{i});
            end
        end
    end

    names=fieldnames(newnames);

    for i=1:length(names)
        len=length(newnames.(names{i}));
        data.(names{i})=cell(1,len);
        for j=1:len
            val=sort(newnames.(names{i}));
            obj=root.(sprintf('%s%d',names{i},val(j)));
            if(isstruct(obj))
                data.(names{i}){j}=snirfdecode(obj);
            else
                data.(names{i}){j}=obj;
            end
        end
        data.(names{i})=cell2mat(data.(names{i}));
    end
end
