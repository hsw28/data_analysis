function axReturn = newpolarplot(hsave)
%NEWPOLARPLOT preamble for NextPlot property for polar axes
%
%  NEWPOLARPLOT prepares figure, axes for graphics according to
%  NextPlot.
%
%  h=NEWPOLARPLOT returns the handle of the prepared axes.
%
%  h=NEWPOLARPLOT(hsave) prepares and returns an axes, but does not
%  delete any objects whose handles appear in hsave. If hsave is
%  specified, the figure and axes containing hsave are prepared
%  instead of the current axes of the current figure. If hsave is
%  empty, newpolarplot behaves as if it were called without any inputs.
%
%  See also HOLD, ISHOLD, FIGURE, AXES, CLA, CLF, NEWPLOT
%

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 5.13.6.4 $  $Date: 2004/08/16 01:47:16 $
%  Built-in function.

%  Copied and modified 01/06/2008 Fabian Kloosterman   


%check arguments
if nargin == 0 || isempty(hsave)
  hsave = [];
elseif length(hsave) ~= 1 || ~ishandle(hsave)
  error('newpolarplot:invalidHandle', 'Invalid handle')
end

%find figure and axes handles, if any
fig = [];
ax = [];

if ~isempty(hsave)
  obj = hsave;
  while ~isempty(obj)
    if strcmp(get(obj,'type'),'figure')
      fig = obj;
    elseif strcmp(get(obj,'type'),'axes')
      ax = obj;
    end
    obj = get(obj,'parent');
  end
end

%create new figure, if we have none
if isempty(fig)
  fig = gcf;
end

%deal with figure nextplot property
fig = ObserveFigureNextPlot(fig, hsave);
set(fig,'nextplot','add');

%get current axes in figure or create one
if isempty(ax)
  ax = get(fig,'CurrentAxes');
  if isempty(ax)
    ax = polaraxes('parent',fig);
  end
elseif ~ishandle(ax)
  error('axis parent deleted')
end

%deal with axes nextplot property
ax = ObserveAxesNextPlot(double(ax), hsave);

%return handle
if nargout
  axReturn = ax;
end


function fig = ObserveFigureNextPlot(fig, hsave)
%
% Helper fcn for preparing figure for nextplot, optionally
% preserving specific existing descendants.
% GUARANTEED to return a figure, even if some crazy combination
% of create / delete fcns deletes it.
%
switch get(fig,'nextplot')
  case 'new'
    % if someone calls plot(x,y,'parent',h) and h is an axes
    % in a figure with NextPlot 'new', ignore the 'new' and
    % treat it as 'add' - just add the axes to that figure.
    if isempty(hsave)
      fig = figure;
    end
  case 'replace'
    clf(fig, 'reset', hsave);
  case 'replacechildren'
    clf(fig, hsave);
  case 'add'
    % nothing    
end
if ~ishandle(fig) && isempty(hsave)
  fig = figure;
end


function ax = ObserveAxesNextPlot(ax, hsave)
%
% Helper fcn for preparing axes for nextplot, optionally
% preserving specific existing descendants
% GUARANTEED to return an axes in the same figure as the passed-in
% axes, even if that axes gets deleted by an overzealous create or
% delete fcn anywhere in the figure.
%

% for performance only call ancestor when needed 
fig = get(ax,'Parent');
if ~strcmp(get(fig,'Type'),'figure')
  fig = ancestor(fig,'figure');
end

switch get(ax,'nextplot')
  case 'replace'
    cla(ax, 'reset',hsave);
    reset(handle(ax));
  case 'replacechildren'
    cla(ax, hsave);
  case 'add'
    % nothing    
end

if ~ishandle(ax) && isempty(hsave)
  if ~ishandle(fig)
    ax = polaraxes;
  else
    ax = polaraxes('parent',fig);
  end
end
