function h=polarscatter(varargin)
%POLARSCATTER polar scatter constructor
%
%  h=POLARSCATTER(param1,var1,...) constructs a polar scatter object with
%  properties set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes (normal or polar axes)
%   AngleUnits - units for angular data ('radians' or 'degrees')
%   AngleData - angle data vector
%   RadiusData - radius data vector
%   SizeData - size data vector
%   ColorData - color data vector/matrix
%   AngleClip - clipping method for angle data (default='clip')
%   RadiusClip - clipping method for radius data (default='clip')
%   LineWidth - line width (default=1)
%   Marker - marker style (default='o')
%   MarkerEdgeColor - color of marker edge (default='flat')
%   MarkerFaceColor - color of marker face (default='flat')
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar scatter parameters in arguments
p = {'AngleData', 'RadiusData', 'SizeData', 'ColorData', 'AngleClip', ...
     'RadiusClip', 'LineWidth', 'Marker', 'MarkerEdgeColor', 'MarkerFaceColor', ...
     'AngleUnits'};

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
h=fkGraphics.polarscatter(varargin{ind}, 'Parent', double(parent));


%-------INITIALIZATION-------

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end

%create scatter object
hAx = ancestor(double(h), 'axes');
holdstatus = ishold(hAx);
hold(hAx,'on');
h.hScatter = scatter( NaN, NaN, NaN, NaN, 'Parent', double(h), ...
                      'LineWidth', h.LineWidth, 'Marker', h.Marker, ...
                      'MarkerEdgeColor', h.MarkerEdgeColor, ...
                      'MarkerFaceColor', h.MarkerFaceColor);
hold(hAx,onoff(holdstatus));

%this object support legends
setappdata(double(h),'LegendLegendInfo',[]);

%we're done initializing
h.Initialized=1;


%-------LISTENERS-------

%create listener for marker properties change
p = [h.findprop('LineWidth') h.findprop('Marker') ...
    h.findprop('MarkerEdgeColor') ...
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
set(h.hScatter, 'LineWidth', h.LineWidth, 'Marker', h.Marker, ...
             'MarkerEdgeColor', h.MarkerEdgeColor, 'MarkerFaceColor', ...
             h.MarkerFaceColor);
%refresh legend
if ~isempty(getappdata(double(h),'LegendLegendInfo'))
  setLegendInfo(h);
end