function h=polaraxes(varargin)
%POLARAXES creates a polar axes
%
%  h=POLARAXES(param1,val1,...) creates a polar axes in the current
%  figure and returns a handle. Optional parameter/value pairs can be
%  specified. For a list of properties execute set(h).
%
%  A polaraxes object is derived from a normal axes with an extra set of
%  properties. There are many axes properties that have no meaning for
%  a polar axes. Some of the axes properties that do have meaning are:
%  'Position', 'Color', 'Font*', 'NextPlot', 'Title', 'Layer'
%

%  Copyright 2008-2008 Fabian Kloosterman


%create polaraxes object
h = fkGraphics.polaraxes(varargin{:});
h.RefreshMode = 'auto';