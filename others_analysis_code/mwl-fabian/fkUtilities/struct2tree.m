function result = struct2tree(s, depth, indent, level)
%STRUCT2TREE show matlab structure or path as tree
%
%  tree=STRUCT2TREE(s) returns a character array representing the tree
%  structure of a path or matlab struct.
%
%  tree=STRUCT2TREE(s,depth) sets the deepest level of the struct or path
%  that will be returned (defaulr = Inf)
%
%  tree=STRUCT2TREE(s,depth,indent) sets the amount of indentation.
%
%  tree=STRUCT2TREE(s,depth,indent,level) sets the current level in the
%  tree (used internally by struct2tree).
%

%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
result = '';

if nargin<2 || isempty(depth)
    depth = Inf;
end

if nargin<3 || isempty(level)
    level = 0;
end

if nargin<4 || isempty(indent)
    indent = 4;
end

if depth == 0
    return
end

if isstruct(s)
    fn = fieldnames(s);
elseif ischar(s)
    try
        s = fullpath(s);
        filelist = dir(s);
        filelist(1:2) = [];
        fn = {filelist.name};
    catch
        return
    end
    
else
    error('struct2tree:invalidArguments', 'Invalid input')
end

%gather field names recursively
for f = 1:length(fn)
    
    result = [result repmat(' ', 1, indent*level) fn{f} '\n'];
    
    if isstruct(s)
        if ~isempty(s) && isstruct(s(1).(fn{f}))
            result = [result struct2tree(s(1).(fn{f}), depth-1, level+1, indent)];
        end
    else
        if (filelist(f).isdir)
            result = [result struct2tree(fullfile(s, fn{f}), depth-1, level+1, indent)];
        end
    end
    
end

result = sprintf(result);
