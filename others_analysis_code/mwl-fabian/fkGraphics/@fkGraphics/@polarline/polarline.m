function h=polarline(varargin)
%POLARLINE polar line constructor
%
%  h=POLARLINE(param1,var1,...) constructs a polar line object with
%  properties set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes (normal or polar axes)
%   AngleUnits - units for angular data ('radians' or 'degrees')
%   AngleData - angle data vector
%   RadiusData - radius data vector
%   AngleClip - clipping method for angle data (default='clip')
%   RadiusClip - clipping method for radius data (default='clip')
%   Color - line color (default=[0 0 0])
%   LineStyle - line style of edge (default='-')
%   LineWidth - line width of edge (default=1)
%   Marker - marker style fo edge (default='o')
%   MarkerSize - marker size (default=6)
%   MarkerEdgeColor - color of marker outline (default=[0 0 0])
%   MarkerFaceColor - color of marker fill (default='none')
%   AutoClose - automatically close line (default='on')
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar area parameters in arguments
p = {'AngleData', 'RadiusData', 'AngleClip', 'RadiusClip', 'LineStyle', ...
     'LineWidth', 'Marker', 'MarkerSize', 'MarkerEdgeColor', ...
     'MarkerFaceColor', 'AngleUnits', 'AutoClose', 'Color'};

ind = find( ismember( lower(varargin(1:2:end)), lower(p) ) );
ind = [2*ind-1;2*ind];
args = varargin(ind(:));

%find parent parameter if any
parent_ind = find( strncmpi( varargin(1:2:end), 'parent',6 ) );
if ~isempty(parent_ind)
  parent = varargin{parent_ind*2};
else
  parent = gca;
end

%find remaining arguments and pass on to constructor
ind = setdiff(1:nargin,ind(:));
h=fkGraphics.polarline(varargin{ind}, 'Parent', double(parent));


%-------INITIALIZATION-------

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end

%create line object
h.hLine = line( NaN, NaN, 'Parent', double(h), 'LineStyle', h.LineStyle, ...
                'LineWidth', h.LineWidth, 'Marker',h.Marker,'MarkerEdgeColor', ...
                h.MarkerEdgeColor, 'MarkerFaceColor', h.MarkerFaceColor, ...
                'Color', h.Color, 'MarkerSize', h.MarkerSize );

%this object support legends
setappdata(double(h),'LegendLegendInfo',[]);

%we're done initializing
h.Initialized=1;

%-------LISTENERS-------

%create listener for when the line properties change
p = [h.findprop('Color') h.findprop('LineStyle') ...
    h.findprop('LineWidth') h.findprop('Marker') ...
    h.findprop('MarkerSize') h.findprop('MarkerEdgeColor') ...
    h.findprop('MarkerFaceColor') ];
l = handle.listener(h, p,'PropertyPostSet', @changedLineProps);

%-------SETTERS/GETTERS-------

%define set/get function angle data
p = h.findprop('AngleData');
set(p, 'GetFunction', @fkGraphics.getAngleData);
set(p, 'SetFunction', @fkGraphics.setAngleData);


%-------FINALIZE-------

%store listeners
h.PropertyListeners = l;

%set refreshmode to auto, which forces a refresh
h.RefreshMode = 'auto';


%-------LISTENER CALLBACK FUNCTIONS-------

function changedLineProps(hProp,eventdata) %#ok
%CHANGEDLINEPROPS set line properties
h=eventdata.affectedObject;
set(h.hLine, 'Color', h.Color, 'LineStyle', h.LineStyle, 'LineWidth', ...
             h.LineWidth, 'Marker', h.Marker, 'MarkerSize', h.MarkerSize, ...
             'MarkerEdgeColor', h.MarkerEdgeColor, 'MarkerFaceColor', ...
             h.MarkerFaceColor);
%refresh legend
if ~isempty(getappdata(double(h),'LegendLegendInfo'))
  setLegendInfo(h);
end