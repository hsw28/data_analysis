function p = struct2param( s, expand )
%STRUCT2PARAM convert structure to parameter/value pairs
%
%  p=STRUCT2PARAM(struct) returns a cell array of parameter/value pairs
%  based on the structure.
%
%  p=STRUCT2PARAM(struct,expand) expands substructures
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1 || isempty(s) || ~isstruct(s)
    p = {};
    return
end


if nargin<2 || ~expand

    %get fieldnames
    fn = fieldnames(s);
    
    %create output cell array
    p = cell(1,2*numel(fn));

    %assign parameter names and values
    p(1:2:end) = fn;
    p(2:2:end) = struct2cell( s );
    
else
    
    p = expand_struct( s, '' );

end


function p = expand_struct(s, parent_path)

fn = fieldnames(s);

p={};

if ~isempty(parent_path)
    parent_path = [parent_path '.'];
end

for k=1:numel(fn)
    
    if isstruct(s.(fn{k}))
        
        p = cat(2, p, expand_struct(s.(fn{k}), [parent_path fn{k}]) );
        
    else
        
        p(end+[1:2]) = {[parent_path fn{k}], s.(fn{k})};
        
    end
    
end