function h=cursor(varargin)
%CURSOR creates a cursor
%
%  h=CURSOR creates a new cursor in the center of the current axes. A
%  handle to the cursor is returned.
%
%  h=CURSOR(x,y) creates a new cursor at coordinates x,y in the current
%  axes.
%
%  h=CURSOR(hax,...) creates a cursor in the axes with handle hax.
%
%  h=CURSOR(...,param1,val1,...) sets cursor properties through
%  parameter/value pairs. Execute set(h) to see a list of valid
%  properties that can be set.
%

%  Copyright 2008-2008 Fabian Kloosterman

%get axes handle from arguments, if any
[hAx,args,nargs] = axescheck(varargin{:}); %#ok

if nargs==0 || ischar(args{1})
  x = [];
  y = [];
elseif nargs<2 || (~isscalar(args{1}) && ~isempty(args{1})) ...
      || (~isscalar(args{2}) && ~isempty(args{2}))
  error('cursor:invalidArgument', 'Invalid x,y coordinates')
else
  x = args{1};
  y = args{2};
  args(1:2)=[];
end
  
if isempty(hAx)
  hAx = gca;
end 
  
if isempty(x)
  x = mean( get(hAx, 'XLim') );
end
if isempty(y)
  y = mean( get(hAx, 'YLim') );
end

h=fkGraphics.cursor(args{:},'Parent', hAx, 'X', x, 'Y', y);