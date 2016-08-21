function report_behavior( position, track )

f = figure;

[Timg, Tx, Ty] = track.Timg( track.image );
Tx = track.Tpos(Tx);
Ty = track.Tpos(Ty);

h = subplot(2,2,1);
image(Tx, Ty, Timg);
colormap gray(256);
hold on;
plot( position.headpos(:,1), position.headpos(:,2) );

fn = fieldnames( track.regions );
for k=1:numel(fn)
    nodes = getcurve( track.regions.(fn{k}) );
    line( nodes(:,1), nodes(:,2), 'Color', [0 1 0]);
    text( mean(nodes(:,1)), mean(nodes(:,2)), fn{k}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', [1 1 0] )
end
for k=1:size(track.segments,1)
    nodes = getcurve( track.segments{k,3} );
    line( nodes(:,1), nodes(:,2), 'Color', [1 0 0]);
end

xlabel( position.units );
ylabel( position.units );
title('Track');

h = subplot(2,2,2);
rate = 30;
[m, edges] = map( position.headpos, 'Grid', {0:200, 0:200} );
m = m./rate;
total_time = nansum( m(:) );
minutes = floor(total_time ./ 60); seconds = rem( total_time, 60 );
plot_map2D(m, 'MapEdges', edges, 'Image', Timg, 'ImageSize', [Tx;Ty], 'Parent', h, 'Title', ['Occupancy Map (total time: ' num2str(minutes) 'min ' num2str(seconds) 's)'], 'Labels', {position.units, position.units, 'seconds'}, 'ColorBar', 1, 'ColorMap', jet(256) )

h = subplot(4,1,3);
plot( position.timestamp, position.headpos(:,1) );
set(h, 'XLim', [min(position.timestamp) max(position.timestamp)]);
xlabel( 'time (s)' );
ylabel( position.units );
title('X coordinate');
cm = jet(256);
%seg_plot( {track.trajectories.laps_forward}, 'Axis', h, 'FaceColor', cm( linspace(1,256,numel(track.trajectories)),: ), 'Alpha', 0.2 );
%seg_plot( {track.trajectories.laps_back}, 'Axis', h, 'FaceColor', cm( linspace(1,256,numel(track.trajectories)),: ), 'Alpha', 0.4 );

h = subplot(4,1,4);
plot( position.timestamp, position.headpos(:,2) );
set(h, 'XLim', [min(position.timestamp) max(position.timestamp)]);
xlabel( 'time (s)' );
ylabel( position.units );
title('Y coordinate');
%seg_plot( {track.trajectories.laps_forward}, 'Axis', h, 'FaceColor', cm( linspace(1,256,numel(track.trajectories)),: ), 'Alpha', 0.2 );
%seg_plot( {track.trajectories.laps_back}, 'Axis', h, 'FaceColor', cm( linspace(1,256,numel(track.trajectories)),: ), 'Alpha', 0.4 );


for k=1:numel(track.trajectories)

    f = figure;

    traj = create_trajectory( track, track.trajectories(k).regions );

    %linearize
    linpos = track.trajectories(k).linearize(position.headpos);
    linspeed = gradient( linpos , 1/rate);
    
    %smooth linspeed
    linspeed = conv2( linspeed, fspecial('gaussian', [30 1], 2), 'same' );
    
    [sel_time, sel_index, sel_data] = seg_select(track.trajectories(k).forward.segments, position.timestamp, [linpos linspeed] );

    %occupancy
    sel_pos = vertcat( sel_data{:} );
    sel_pos = sel_pos(:,1);
    m = map( sel_pos, 'Grid', {0:200} );

    h = subplot( 3,2,1 );
    plot( m./rate );

    set( h, 'XLim', [0 length(traj) ]);

    h = subplot( 3,2,3 );

    for l=1:numel( sel_time ) 
        
        line( sel_time{l} - sel_time{l}(1), sel_data{l}(:,1) );

    end
    
    h = axismatrix( numel(sel_time), 1, 'Parent', f, 'Position', [0.5 0 0.5 1], 'YSpacing', 0);
    
    maxtime = -Inf;
    
    for l=1:numel(sel_time)
        
        axes( h(l) );
        plot( sel_time{l} - sel_time{l}(1), sel_data{l}(:,2) );
        %plot( sel_data{l}(:,1), sel_data{l}(:,2) );
        
        maxtime = max( maxtime, sel_time{l}(end)-sel_time{l}(1) );
        
    end
    
    sel_speed = vertcat( sel_data{:} );
    sel_speed= sel_speed(:,2);
    set(h, 'YLim', [0 max( sel_speed )], 'XLim', [0 maxtime]);
    set(h(1:end-1), 'XTick', [], 'YTick', []);
    
    h = subplot( 3,2,5 );
    
    hist( sel_speed, 101 );
    
end