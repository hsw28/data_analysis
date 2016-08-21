function hTree = explore( L, varargin )
%EXPLORE visually explore diagnostics object
%
%  h=EXPLORE(d,...) opens a window and shows the contents of a
%  diagnostics object in a tree. The function returns the handle of the
%  uitree. This function supports the same options as explorestruct
%
%  See also: explorestruct
%

%  Copyright 2005-2008 Fabian Kloosterman


[dummy, rootlabel, extension, dummy] = fileparts( L.filename); %#ok
hTree = explorestruct( diag2struct(L), 'RootLabel', [rootlabel extension], ...
                       varargin{:});
