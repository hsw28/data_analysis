function plot_replay_summary( R, Rrank, pvalue, plots, L )
%PLOT_REPLAY_SUMMARY
%
%  PLOT_REPLAY_SUMMARY(r)
%
%  PLOT_REPLAY_SUMMARY(r,pvalue,plots)
%

if nargin<2
  help(mfilename)
  return
end

if nargin<3 || isempty(pvalue)
  pvalue = 0.001;
end

if nargin<4 || isempty(plots)
  plots = {'track'};
elseif ~all( ismember( plots, {'track', 'animal', 'centered'} ) )
  error('plot_replay_summary:invalidArgument', 'Invalid plots arguments');
end

if nargin<5 || isempty(L) || any(~ishandle(L)) || numel(L)~=numel(plots)
  L = [];
end

N = find( [R.target(Rrank.pvalue).pvalue]<pvalue, 1, 'last' );

if isempty(N)
  return
end

pos_scale_factor = 0.01;

posgrid = eval( R.info.posgrid );

idx = Rrank.pvalue(1:N);

replaydir = [R.target(idx).replay_dir];
replaymap = [R.target(idx).replay_map];
replaymatch = replaydir.*replaymap;

inbound_facing = cos( vertcat(R.target(idx).animal_lindir) ) < 0;

%setup colors
ncolors = 11;
colmap = multicolor( [1 0.5 0; 1 1 0; 0 0.5 0], ncolors );
col = colmap( round( (replaymatch+1).*( (ncolors-1)./2)+1 ), : );

if isempty(L)
  
  %create figure
  hFig = figure('colormap', colmap);

  %create axes
  L = layoutmanager( hFig, numel(plots), 1, 'xspacing', 12, 'xoffset', 20, ...
                     'yoffset', 4, 'yspacing', 4);
  
else
  
  set( get(L(1), 'parent'), 'colormap', colmap );
  
end

for k=1:numel(plots)
  
  animal_pos = vertcat( R.target(idx).animal_linpos );
  p = vertcat( R.target(idx).linepos );
  pt = vertcat( R.target(idx).linetime);
  
  if ismember( plots{k}, {'animal', 'centered'})
    p = p - repmat(animal_pos,1,2);
    animal_pos(:) = 0;
  end
  
  if strcmp(plots{k}, 'animal')
    p = p.*repmat( sign( cos( vertcat(R.target(idx).animal_lindir) ) ), ...
                   1, 2);
    flip = true;
  else
    flip = false;
  end
  
  axes( L(k) );
  hold on;
  
  if ismember( plots{k}, {'centered', 'animal'} )
    yl = [-1 1].*diff( posgrid( [1 end] ) );
  else
    yl = [min(R.info.behavior.variables(:,1)) ...
              max(R.info.behavior.variables(:,1))];
  end
  
  %plot behavior
  if strcmp( plots{k}, 'track')
    line( R.info.behavior.time, pos_scale_factor.*R.info.behavior.variables(:,1), ...
          'Color', [0.8 0.8 0.8], 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 10);
  end
  
  %loop trough all selected replay events
  for j=1:numel(idx)
    
    T = mean( R.target(idx(j)).segment );
    
    %line( [T T], pos_scale_factor.*yl, 'Color', [0.8 0.8 0.8], 'LineStyle', ':');
    
    line( pt(j,:), pos_scale_factor.*p(j,:), 'LineWidth', 2, 'Color', col(j,:) );
    
    
    if replaydir(j)<0
      if inbound_facing(j) && flip
        symbol = '^';
      else
        symbol = 'v';
      end
      plot( pt(j,1), pos_scale_factor.*p(j,1), 'LineStyle', 'none', 'Color', col(j,:), 'Marker', ...
            'o', 'MarkerFaceColor', col(j,:));
      plot( pt(j,2), pos_scale_factor.*p(j,2), 'LineStyle', 'none', 'Color', col(j,:), 'Marker', ...
            symbol, 'MarkerFaceColor', col(j,:), 'MarkerSize', 7);    
    else
      if inbound_facing(k) && flip
        symbol = 'v';
      else
        symbol = '^';
      end    
      plot( pt(j,1), pos_scale_factor.*p(j,1), 'LineStyle', 'none', 'Color', col(j,:), 'Marker', ...
            'o', 'MarkerFaceColor', col(j,:));
      plot( pt(j,2), pos_scale_factor.*p(j,2), 'LineStyle', 'none', 'Color', col(j,:), 'Marker', ...
            symbol, 'MarkerFaceColor', col(j,:), 'MarkerSize', 7);    
    end
    
    if ~flip
      if inbound_facing(j)
        line( T, pos_scale_factor.*animal_pos(j), 'Marker', 'v', 'Color', ...
              [0 0 0], 'MarkerFaceColor', 'none', 'MarkerSize', 7, ...
              'LineWidth', 2, 'LineStyle', 'none');
      else
        line( T, pos_scale_factor.*animal_pos(j), 'Marker', '^', 'Color', ...
              [0 0 0], 'MarkerFaceColor', 'none', 'MarkerSize', 7, ...
              'LineWidth', 2, 'LineStyle', 'none');
      end  
    end    
    
  end
  
  %set(gca, 'YDir', 'reverse');
  set(gca, 'YLim', pos_scale_factor.*yl, 'FontSize', 14 );
  
  
  
end

%set( L(:), 'View', [-90 90] );
set( L(end), 'CLim', [-1 1] );
colorbar('Peer', L(end) );
