function reset(h)
%RESET reset polar axes properties
%
%  RESET(h) resets all polar axes properties to initial state
%

%  Copyright 2008-2008 Fabian Kloosterman

%disable listeners
set(h.PropertyListeners,'Enabled','off')
set( getappdata(0,'PolarAxesListeners'), 'Enabled', 'off');

%no zooming/panning
b=hggetbehavior(double(h),'zoom');
set(b, 'Enable', false);
b=hggetbehavior(double(h),'pan');
set(b, 'Enable', false);

%reset axes properties
set(h, 'DataAspectRatio', [1 1 1], ...
       'PlotBoxAspectRatioMode', 'auto', ...
       'CameraPosition', [0 0 10], ...
       'CameraTarget', [0 0 0.5], ...
       'CameraUpVector', [0 1 0], ...       
       'CameraViewAngle', 13.2, ...
       'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1]);
axis(h,'off');

%there must be a better way of resetting the properties...
p = {'AngleUnits' 'radians'
     'AxesRotation' 0
     'AngleDir' 'ccw'
     'FontColor' [0 0 0]
     'FontAngle' 'normal'
     'FontName' 'Helvetica'
     'FontUnits' 'points'
     'FontWeight' 'normal'
     'RadialGridLineStyle' ':'
     'RadialGridColor' [0.5 0.5 0.5]
     'RadialGridLineWidth' 1
     'RadialGridVisible' 'on'
     'AngleGridLineStyle' '-'
     'AngleGridColor' [0.5 0.5 0.5]
     'AngleGridLineWidth' 1
     'AngleGridVisible' 'on'
     'AngleTickLabelsVisible' 'on'
     'RadialTickLabelsVisible' 'on'
     'RadialAxisLineStyle' '-'
     'RadialAxisColor' [0 0 0]
     'RadialAxisLineWidth' 1
     'RadialAxisVisible' 'on'
     'AngleAxisLineStyle' '-'
     'AngleAxisColor' [0 0 0]
     'AngleAxisLineWidth' 1
     'AngleAxisVisible' 'on'
     'AngleLim' [0 0.1]
     'RadialLim' [0 0.1]
     'AngleTickUnits' 'radians'
     'AngleTickValues' 'auto'
     'AngleTickLabels' 'auto'
     'AngleTickDir' 'both'
     'AngleTickSign' 'unsigned'
     'RadialDir' 'normal'
     'RadialAxisRotation' 5*pi/12
     'RadialTickUnits' ''
     'RadialTickValues' 'auto'
     'RadialTickLabels' 'auto'
     'RadialTickLabelsOffset' 0.03
     'RadialTickLabelsAngle' 'auto'
     'RadialTickLength' 0.025
     'RadialTickDir' 'both'
     'AngleTickLength' 0.025
     'AngleTickLabelsOffset' 0.1
     }';

set(h, p{:});

%enable listeners
set(h.PropertyListeners,'Enabled','on')
set( getappdata(0,'PolarAxesListeners'), 'Enabled', 'on');

%trigger refresh
set(h, 'AngleLim', [0 2*pi] );
set(h, 'RadialLim', [0 1] );
set(h, 'Color', [1 1 1]);


     
     
     