function demo_polar
%DEMO_POLAR show off polar axes and plots
%
%  DEMO_POLAR show a figure with example polar plots.
%

hFig = figure;
hAx = handle([]);

for k=1:2
  for j=1:2
    
    x = 0.1+(k-1).*0.45;
    y = 1-j.*0.45;
    w = 0.35;
    h = 0.35;

    hAx(k,j) = polaraxes( 'Parent', hFig, ...
                          'Position', [x y w h] );
    
  end
  
end

polarline(hAx(1,1));

set( hAx(1,1), 'Style', 'compass', 'AngleUnits', 'degrees', ...
               'RadialAxisRotation', 20, 'AngleTickUnits', 'degrees', ...
               'AngleAxisColor', [0 0 1], 'AngleGridColor', [0 0 1], ...
               'RadialGridColor', [0 0 1]);

polarbar(hAx(1,2));

polararea(hAx(2,1), 'FaceColor', [0.75 0 0], 'Alpha', 1);

set( hAx(2,1), 'AngleTickSign', 'signed', 'Color', [1 1 0.75], 'Layer', 'top');

polarscatter(hAx(2,2));