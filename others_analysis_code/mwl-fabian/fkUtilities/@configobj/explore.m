function hTree = explore(C, varargin)
%EXPLORE visually explore configobj
%
%  h=EXPLORE(c,...) Opens a window and shows the contents of a configobj
%  in a tree. The function returns the handle of the uitree. This
%  function takes the same options as explorestruct.
%
%  See also: EXPLORESTRUCT
%

%  Copyright 2005-2008 Fabian Kloosterman


%set rootlabel
rootlabel = inputname(1);
if isempty(rootlabel)
  rootlabel = 'configobj';
end

%explore structure and return handle to 
hTree = explorestruct( config2struct(C), 'RootLabel', rootlabel, varargin{:} );
