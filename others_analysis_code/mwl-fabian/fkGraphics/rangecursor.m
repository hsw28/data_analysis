function h=rangecursor(varargin)
%RANGECURSOR creates a cursor
%
%  h=RANGECURSOR creates a new range cursor in the center of the current
%  axes. A handle to the cursor is returned.
%
%  h=RANGECURSOR(xrange,yrange) creates a new range cursor with specified x
%  and y ranges in the current axes.
%
%  h=RANGECURSOR(hax,...) creates a cursor in the axes with handle hax.
%
%  h=RANGECURSOR(...,param1,val1,...) sets range cursor properties through
%  parameter/value pairs. Execute set(h) to see a list of valid
%  properties that can be set.
%

%  Copyright 2008-2008 Fabian Kloosterman


%get axes handle from arguments, if any
[hAx,args,nargs]  = axescheck(varargin{:}); %#ok

if nargs==0 || ischar(args{1})
  x=[];
  y=[];
elseif nargs<2 || (~isequal(size(args{1}), [1 2]) && ~isempty(args{1})) ...
      || (~isequal(size(args{2}),[1 2]) && ~isempty(args{2}))
  error('rangecursor:invalidArgument', 'Invalid x and/or y ranges')
else
  x = args{1};
  y = args{2};
  args(1:2)=[];
end

if isempty(hAx)
  hAx = gca;
end
  
if isempty(x)
  xl = get(hAx,'XLim');
  x = [-0.25 0.25].*diff(xl)+mean(xl);
end
if isempty(y)
  yl = get(hAx,'YLim');  
  y = [-0.25 0.25].*diff(yl)+mean(yl);
end

h=fkGraphics.rangecursor(args{:},'Parent', hAx, 'XLim', x, 'YLim', y);