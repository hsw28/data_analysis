function show_env(env, hAx)
%SHOW_ENV plot environment definition
%
%  SHOW_ENV(environment) show the environment definition in a new figure
%
%  SHOW_ENV(environment,hax) show environment definition in specified
%  axes
%


if nargin<2
  hFig = figure('colormap', gray(256)); %#ok
  hAx = axes;
end

if ~isempty(env.video.still)
  image( env.video.image_xdata, env.video.image_ydata, env.video.still, 'parent', hAx );
  set( hAx, 'clim', [0 255], 'ydir', 'normal' );
end

title(hAx, env.name, 'fontsize', 12);
xlabel(hAx, env.units);
ylabel(hAx, env.units);

for k=1:numel(env.definition.regions)
  plotpolyline( env.definition.regions(k), 'parent', hAx, 'color', [0 1 0] );
  txt_pos = mean( env.definition.regions(k).nodes );
  text( txt_pos(1), txt_pos(2), env.definition.regions(k).name, ...
        'horizontalalignment', 'center', 'color', [0 1 0], 'parent', hAx);
end

for k=1:numel(env.definition.polylines)
  plotpolyline( env.definition.polylines(k), 'parent', hAx, 'color', [1 0 0]);  

  if isfield( env.definition.polylines, 'length' )
    delta = 10.^round( log10( env.definition.polylines(k).length ) - 1 );
    t = 0:delta:env.definition.polylines(k).length;
    xy = env.definition.polylines(k).inv_linearize( t' );
    
    line( xy(:,1), xy(:,2), 'LineStyle', 'none', 'MArker', 'o', 'MarkerFaceColor', ...
          [1 0 0], 'MarkerEdgeColor', [1 0 0], 'Parent', hAx );
  end
end

for k=1:numel(env.definition.circles)
  plotcircle(env.definition.circles(k).center, env.definition.circles(k).radius, ...
              'parent', hAx, 'edgecolor', [1 0 0] );
end

for k=1:numel(env.video.roi)
    rectangle('Position', env.video.roi(k).position, 'EdgeColor', [0 0 1], 'Parent', hAx );
    pos = env.video.roi(k).position([1 2]) + [0 env.video.roi(k).position(4)];
    text( pos(1), pos(2), env.video.roi(k).name, 'horizontalalignment', 'left', 'verticalalignment', 'top', 'color', [0 0 1], 'parent', hAx);
end
