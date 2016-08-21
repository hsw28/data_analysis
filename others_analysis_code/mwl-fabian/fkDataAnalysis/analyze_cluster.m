function varargout = analyze_cluster1( rootdir, epoch, cluster_idx )

if nargin<2
    help(mfilename)
    return
end

epoch_rootdir = fullfile( rootdir, 'epochs', epoch);

%========TRACK=============================================================
%==========================================================================
%tracker sampling frequency
Fs_tracker = 30;

%import track
track = import_track( epoch_rootdir );

%transform image
[Timg, Tx, Ty] = track.Timg( track.image );
Tx = track.Tpos(Tx);
Ty = track.Tpos(Ty);

%========POSITION==========================================================
%==========================================================================
%import position (time, headpos, headdir, velocity)
%and transform to track coordinates
velocity_smooth_stdev = 0.5; %in seconds
pos = selectfields( import_position( epoch_rootdir, track, velocity_smooth_stdev ), {'timestamp', 'headpos', 'headdir', 'velocity'} );

%========TRAJECTORIES======================================================
%==========================================================================
%process trajectories (find forward and back laps)
trajectories = process_trajectories( track, pos, 1 );

%========CLUSTERS==========================================================
%==========================================================================
%import clusters
clusters = import_clusters( epoch_rootdir );

if nargin<3 || isempty(cluster_idx)
    cluster_idx = [1:numel(clusters)];
end
clusters = clusters(cluster_idx);

%========CLUSTERS BEHAVIOR=================================================
%==========================================================================
%assign behavior to spikes
cluster_behavior = applyfcn( @(t) applyfcn( @(prop) interp1( pos.timestamp, prop, t, 'nearest'), [], selectfields(pos, {'headpos', 'headdir', 'velocity'}) ),[], {clusters.timestamp} );
%save cluster behavior

applyfcn( @(name, prop) save_props( fullfile( epoch_rootdir, 'clusters'), name, prop ), [], {clusters.name}, cluster_behavior );

%convert to struct array
cluster_behavior = vertcat( cluster_behavior{:} );

%========2D RATE MAPS======================================================
%==========================================================================
speed_filter = [2 Inf];
pos_filter = create_filter( abs(pos.velocity), speed_filter );
cluster_filter = applyfcn( @(v) create_filter( abs(v), speed_filter ), [], {cluster_behavior.velocity});
%find grid size closest to 2 cm that gives a whole number of bins
binsize = 2;
nbins_x = round( diff(Tx) ./ binsize);
nbins_y = round( diff(Ty) ./ binsize );
edges = {linspace(Tx(1), Tx(2), nbins_x), linspace(Ty(1), Ty(2), nbins_y)};
map2d = applyfcn( @(cl, cl_filter, p) rate_map( cl(cl_filter,:), p, 'Grid', edges, 'SampleFreq', Fs_tracker), pos.headpos(pos_filter,:), {cluster_behavior.headpos}, cluster_filter);

applyfcn( @(name, m) save_props( fullfile( epoch_rootdir, 'clusters'), name, struct('ratemap2d', struct('created', datestr( now ), 'map', m, 'edges', { edges }, 'speed_filter', speed_filter, 'binsize', binsize ) ) ), [], {clusters.name}, map2d );



%========FOR EACH TRAJECTORY===============================================
%==========================================================================
for t = 1:numel(trajectories)
    
    %========LINEAR BEHAVIOR===============================================
    %======================================================================
    %linearize position
    linear.headpos = trajectories(t).linearize( pos.headpos );
    %calculate linearized velocity
    linear.velocity = smoothn( gradient( linear.headpos, 1./Fs_tracker ), velocity_smooth_stdev, 1./Fs_tracker);

    %========CLUSTERS LINEAR BEHAVIOR======================================
    %======================================================================
    cluster_linear = applyfcn( @(t) applyfcn( @(prop) interp1( pos.timestamp, prop, t, 'nearest'), [], linear ),[], {clusters.timestamp} );
    %save linearized cluster behavior
    %applyfcn( @(name, prop) save_props( fullfile( epoch_rootdir, 'clusters'), name, struct( 'trajectories', struct( trajectories(t).name,  prop ) ) ), [], {clusters.name}, cluster_linear );
    
    cluster_linear = vertcat( cluster_linear{:} );   

    %========FILTERS=======================================================
    %======================================================================
    speed_threshold = speed_filter(1);
    filters.forward = inseg(pos.timestamp, trajectories(t).forward.segments) & linear.velocity>=speed_threshold;
    filters.back = inseg(pos.timestamp, trajectories(t).back.segments) & linear.velocity<=-speed_threshold;
    cluster_filters.forward = applyfcn( @(time, vel) inseg(time, trajectories(t).forward.segments) & vel>=speed_threshold, [], {clusters.timestamp}, {cluster_linear.velocity});
    cluster_filters.back = applyfcn( @(time, vel) inseg(time, trajectories(t).back.segments) & vel<=-speed_threshold, [], {clusters.timestamp}, {cluster_linear.velocity});

    %========MEAN RATES====================================================
    %======================================================================     
    mean_rate.forward = applyfcn( @(time) Fs_tracker .* numel(find(time)) ./ numel(find(filters.forward)), [], cluster_filters.forward);
    mean_rate.back = applyfcn( @(time) Fs_tracker .* numel(find(time)) ./ numel(find(filters.back)), [], cluster_filters.back);
    
    %========1d RATE MAPS==================================================
    %======================================================================    
    binsize = 2;
    L = length(trajectories(t).traject);
    nbins = round( L ./ binsize );    
    
    edges = linspace(0,L,nbins);
    
    occupancy.forward = map( linear.headpos(filters.forward), 'Grid', {edges} );
    maps.forward = applyfcn( @(p, f) Fs_tracker.*map( p(f), 'DefaultValue', 0, 'Grid', {edges})./occupancy.forward, [], {cluster_linear.headpos}, cluster_filters.forward);
    occupancy.back = map( linear.headpos(filters.back), 'Grid', {edges} );
    maps.back = applyfcn( @(p, f) Fs_tracker.*map( p(f), 'DefaultValue', 0, 'Grid', {edges})./occupancy.back, [], {cluster_linear.headpos}, cluster_filters.back);
           

    %========PLACE FIELD BOUNDARIES========================================
    %======================================================================   
    place_fields.forward = applyfcn( @(m) place_fields_1d( edges, m, 'maxmin', 1 ), [], maps.forward );
    place_fields.back = applyfcn( @(m) place_fields_1d( edges, m, 'maxmin', 1 ), [], maps.back );
    %place_fields.forward = applyfcn( @(m, tr) edges( seg_filterlen( event2seg( find( diff( [0; m(:)>=tr; 0] )==1 ), find( diff( [0; m(:)>=tr; 0] )==-1 ) ), 3) ), [], maps.forward, threshold.forward);
    %place_fields.back = applyfcn( @(m, tr) edges( seg_filterlen( event2seg( find( diff( [0; m(:)>=tr 0] )==1 ), find( diff( [0 m(:)>=tr 0] )==-1 ) ), 3) ), [], maps.back, threshold.back);
    
    %place field filters
    place_field_filters.forward = applyfcn( @(pf) applyfcn( @(b) inseg(linear.headpos, b), [], mat2cell( pf.boundaries, ones( size(pf.boundaries,1),1), 2 ) ), [], place_fields.forward );
    place_field_filters.back = applyfcn( @(pf) applyfcn( @(b) inseg(linear.headpos, b), [], mat2cell( pf.boundaries, ones( size(pf.boundaries,1),1), 2 ) ), [], place_fields.back );
    cluster_field_filters.forward = applyfcn( @(pf, cl) applyfcn( @(b,p) inseg(p, b), cl, mat2cell( pf.boundaries, ones( size(pf.boundaries,1),1), 2 ) ), [], place_fields.forward, {cluster_linear.headpos} );
    cluster_field_filters.back = applyfcn( @(pf, cl) applyfcn( @(b,p) inseg(p, b), cl, mat2cell( pf.boundaries, ones( size(pf.boundaries,1),1), 2 ) ), [], place_fields.back, {cluster_linear.headpos} );
    
    %========LAP BASED ANALYSIS============================================
    %======================================================================
    %create three-level nested cell arrays:
    %clusters - place field - lap
    
    laps.forward = applyfcn( @(cl) applyfcn( @(b) lappify(trajectories(t).forward.segments, pos.timestamp(filters.forward & b), linear.headpos(filters.forward & b ) ) , [], cl) , [], place_field_filters.forward );
    laps.back = applyfcn( @(cl) applyfcn( @(b) lappify(trajectories(t).back.segments, pos.timestamp(filters.back & b), linear.headpos(filters.back & b ) ) , [], cl) , [], place_field_filters.back );
       
    laps.cluster_forward = applyfcn( @(cl, tm, p, f) applyfcn( @(b) lappify(trajectories(t).forward.segments, tm(f & b), p(f & b ) ) , [], cl) , [], cluster_field_filters.forward, {clusters.timestamp}, {cluster_linear.headpos}, cluster_filters.forward );
    laps.cluster_back = applyfcn( @(cl, tm, p, f) applyfcn( @(b) lappify(trajectories(t).back.segments, tm(f & b), p(f & b ) ) , [], cl) , [], cluster_field_filters.back, {clusters.timestamp}, {cluster_linear.headpos}, cluster_filters.back );
    
    %turn off warnings
    warning off
    
    %per lap rate
    laps.rate_forward = applyfcn( @(cl_p, cl_clp) applyfcn( @(cl_pf, cl_clpf) cell2mat( applyfcn( @(p_lap, cl_lap) Fs_tracker.*numel(cl_lap)./numel(p_lap), [], cl_pf, cl_clpf) ), [], cl_p, cl_clp ), [], laps.forward, laps.cluster_forward );
    laps.rate_back = applyfcn( @(cl_p, cl_clp) applyfcn( @(cl_pf, cl_clpf) cell2mat( applyfcn( @(p_lap, cl_lap) Fs_tracker.*numel(cl_lap)./numel(p_lap), [], cl_pf, cl_clpf) ), [], cl_p, cl_clp ), [], laps.back, laps.cluster_back );
    %per lap number of spikes
    laps.nspikes_forward = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) numel( cl_lap ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_forward );
    laps.nspikes_back = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) numel( cl_lap ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_back );   
    %per lap in field occupancy
    laps.occupancy_forward = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) numel(cl_lap)./Fs_tracker, [], cl_clpf) ), [], cl_clp ), [], laps.forward );
    laps.occupancy_back = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) numel(cl_lap)./Fs_tracker, [], cl_clpf) ), [], cl_clp ), [], laps.back );    
    %per lap field width
    laps.width_forward = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) diff( cl_lap([1 end]) ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_forward );
    laps.width_back = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) diff( cl_lap([1 end]) ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_back );   
    %coefficient of variation ( standard deviation / mean )
    laps.cov_forward = applyfcn( @(cl) applyfcn( @(pf) nanstd( pf ) ./ nanmean( pf ), [], cl), [], laps.rate_forward);
    laps.cov_back = applyfcn( @(cl) applyfcn( @(pf) nanstd( pf ) ./ nanmean( pf ), [], cl), [], laps.rate_back);
    %per lap place field center
    laps.lapcenter_forward = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) nanmean( cl_lap ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_forward );
    laps.lapcenter_back = applyfcn( @(cl_clp) applyfcn( @(cl_clpf) cell2mat( applyfcn( @(cl_lap) nanmean( cl_lap ), [], cl_clpf) ), [], cl_clp ), [], laps.cluster_back );
    %place field center
    laps.center_forward = applyfcn( @(cl) applyfcn( @(pf) nanmean( cat(1, pf{:}) ), [], cl), [], laps.cluster_forward);
    laps.center_back = applyfcn( @(cl) applyfcn( @(pf) nanmean( cat(1, pf{:}) ), [], cl), [], laps.cluster_back);
   
    %turn on warnings
    warning on
    
    %now we'll create a big structure with all the info and save it for
    %each cluster
    
    for cc = 1:numel(clusters)
        
        tmp_forward = struct( 'boundary', mat2cell( place_fields.forward{cc}.boundaries, ones( size(place_fields.forward{cc}.boundaries,1),1), 2 ), 'filter', cluster_field_filters.forward{cc}, ...
            'rate', laps.rate_forward{cc}, 'nspikes', laps.nspikes_forward{cc}, 'occupancy', laps.occupancy_forward{cc}, 'width', laps.width_forward{cc}, 'cov', laps.cov_forward{cc}, 'center', laps.center_forward{cc}, 'lapcenter', laps.lapcenter_forward{cc});
        tmp_forward = struct( 'filter', cluster_filters.forward{cc}, 'mean_rate', mean_rate.forward{cc}, 'map', maps.forward{cc}, 'edges', edges, 'binsize', binsize, 'speed_filter', speed_filter, 'place_field_threshold', place_fields.forward{cc}.threshold, 'n_laps', size(trajectories(t).forward.segments,1),...
            'place_fields', tmp_forward);
        tmp_back = struct( 'boundary', mat2cell( place_fields.back{cc}.boundaries, ones( size(place_fields.back{cc}.boundaries,1),1), 2 ), 'filter', cluster_field_filters.back{cc}, ...
            'rate', laps.rate_back{cc}, 'nspikes', laps.nspikes_back{cc}, 'occupancy', laps.occupancy_back{cc}, 'width', laps.width_back{cc}, 'cov', laps.cov_back{cc}, 'center', laps.center_back{cc}, 'lapcenter', laps.lapcenter_back{cc});
        tmp_back = struct( 'filter', cluster_filters.back{cc}, 'mean_rate', mean_rate.back{cc}, 'map', maps.back{cc}, 'edges', edges, 'binsize', binsize, 'speed_filter', speed_filter, 'place_field_threshold', place_fields.back{cc}.threshold, 'n_laps', size(trajectories(t).back.segments,1),...
            'place_fields', tmp_back);        
        tmp = struct( 'linpos', cluster_linear(cc).headpos, 'linvelocity', cluster_linear(cc).velocity, ...
            'forward', tmp_forward, 'back', tmp_back);
        tmp = struct( 'trajectories', struct( trajectories(t).name, tmp ) );
        
        save_props( fullfile( epoch_rootdir, 'clusters'), clusters(cc).name, ...
                    tmp, 1 );
        
    end
    
     
    save_props( fullfile( epoch_rootdir, 'position'), 'position.p', struct( 'trajectories', struct( trajectories(t).name, struct( 'linpos', linear.headpos, 'linvelocity', linear.velocity, 'forward', struct('occupancymap', occupancy.forward, 'edges', edges, 'binsize', binsize, 'filter', find(filters.forward), 'speed_filter', speed_filter ), 'back', struct('occupancymap', occupancy.back, 'edges', edges, 'filter', find(filters.back), 'speed_filter', sort(-speed_filter) ) ) ) ), 1 );
    

end


return

%find grid size closest to 2 cm that gives a whole number of bins
nbins_x = round( diff(Tx) ./ 2 );
nbins_y = round( diff(Ty) ./ 2 );

ncol = numel(trajectories)*3 + 1;
[h,f] = axismatrix( numel(cluster_idx), ncol, 'RowsPerPage', 6, 'YOffset', 0.05, 'YSpacing', 0.05 );
set(f, 'ColorMap', gray(256) );

speed_threshold = 2;

%create lap filters using inseg

%for each trajectory
%linearize behavior
%assign linear behavior to spikes
%create filters (velocity, position)
%apply filters


%for each cluster
nc=0;
% for c = cluster_idx
% 
%     nc = nc+1;
%     %construct 2D rate map
%     [rm, edges] = rate_map( clusters(nc).behavior.headpos, pos.headpos, 'Grid', {linspace(Tx(1), Tx(2), nbins_x), linspace(Ty(1), Ty(2), nbins_y)} );
%     %smooth map
%     rm = smooth_map( rm, 3 );
%     plot_map2D( rm, 'MapEdges', edges, 'Image', Timg, 'ImageSize', [Tx;Ty], 'Parent', h(nc,1), 'ColorBar', 0, 'Labels', {'cm', 'cm', 'Hz'}, 'ColorMap', jet(256), 'Scale', [0 max(10, max(rm(:)))]);
%     title(h(nc,1), clusters(nc).name, 'Interpreter', 'none');
% 
% end


%for each trajectory
for t = 1:numel(trajectories)
    
    L = length(trajectories(t).traject);
    nbins = round( L ./ 2 );
    
    [behavior.linpos, behavior.linvelocity] = calc_trajectory_behavior( trajectories(t), pos);
    cl_lin_behavior = calc_cluster_behavior( {clusters.timestamp}, pos.timestamp, behavior );
    
    %filter data
    idx = find( behavior.linvelocity>=2 );
    behavior = applyfcn( @(f) f(idx,:), [], behavior );
    
    tmp = vertcat( cl_lin_behavior{:} )
    idx = applyfcn( @(prop) find( prop>=2 ), [], {tmp.linvelocity} );
    cl_lin_behavior = applyfcn( @(ii, s) applyfcn( @(f) f(ii,:), [], s), [], idx', cl_lin_behavior);
    
    %mean firing rates
    forward_rate = firingrate( {clusters.timestamp}, trajectories(t).forward.segments )
    back_rate = firingrate( {clusters.timestamp}, trajectories(t).back.segments )
    run_rate = firingrate( {clusters.timestamp}, seg_or( trajectories(t).forward.segments, trajectories(t).back.segments ) )
    
    %lappify position
    forward_lap_all = lappify( trajectories(t).forward.segments, {pos.timestamp}, {behavior});
    back_lap_all = lappify( trajectories(t).back.segments, {pos.timestamp}, {behavior});
    forward_lap_all = vertcat( forward_lap_all{:} );
    back_lap_all = vertcat( back_lap_all{:} );
    
    %lappify clusters
    forward_lap = vertcat( lappify( trajectories(t).forward.segments, {clusters.timestamp}', cl_lin_behavior) );
    back_lap = vertcat( lappify( trajectories(t).back.segments, {clusters.timestamp}', cl_lin_behavior) );
    forward_lap = vertcat( forward_lap{:} );
    back_lap = vertcat( back_lap{:} );
    
    %calculate rate maps
    [rm_forward, edges] = rate_map( {forward_lap.linpos}, forward_lap_all.linpos, 'Grid', {linspace(0,L,nbins)});
    [rm_back, edges] = rate_map( {back_lap.linpos}, back_lap_all.linpos, 'Grid', {linspace(0,L,nbins)});
    
    %plot rate maps
    nc = 0;
    for c=cluster_idx
        nc=nc+1;
        axes(h(nc,1+(t-1)*3+2));
        patch( [edges{1}(1:end-1) ; edges{1}(2:end) ; edges{1}(2:end) ; edges{1}(1:end-1)], [zeros(2,numel(rm_forward{nc})) ; rm_forward{nc}' ; rm_forward{nc}'], [0.5 0.5 1] );
        patch( [edges{1}(1:end-1) ; edges{1}(2:end) ; edges{1}(2:end) ; edges{1}(1:end-1)], [zeros(2,numel(rm_back{nc})) ; -rm_back{nc}' ; -rm_back{nc}'], [1 0.5 0.5] );
    end

end

return

%for each cluster
nc = 0;
for c = cluster_idx

    nc = nc+1;
    fprintf(['Currently working on cluster ' num2str(c) '(' clusters(nc).name ')\n'] );
    
    %construct 2D rate map
    [rm, edges] = rate_map( clusters(nc).behavior.headpos, pos.headpos, 'Grid', {linspace(Tx(1), Tx(2), nbins_x), linspace(Ty(1), Ty(2), nbins_y)} );
    %smooth map
    rm = smooth_map( rm, 3 );
    plot_map2D( rm, 'MapEdges', edges, 'Image', Timg, 'ImageSize', [Tx;Ty], 'Parent', h(nc,1), 'ColorBar', 0, 'Labels', {'cm', 'cm', 'Hz'}, 'ColorMap', jet(256));
    title(h(nc,1), clusters(nc).name, 'Interpreter', 'none');
    
    for t = 1:numel(trajectories)
        nbins = round( length(trajectories(t).traject) ./ 2 );

        %filter all positions for speed
        forward_idx_pos = find( trajectories(t).linspeed_forward > speed_threshold );
        back_idx_pos = find( trajectories(t).linspeed_back > speed_threshold );
        
        %find spikes for forward and back laps for this trajectory
        [dummy, idx_forward_laps] = seg_select( trajectories(t).laps_forward, clusters(nc).timestamp );
        [dummy, idx_back_laps] = seg_select( trajectories(t).laps_back, clusters(nc).timestamp );
        
        idx_forward = vertcat( idx_forward_laps{:} );
        idx_back = vertcat( idx_back_laps{:} );

        %find linear speed @ spike times
        speed_forward = interp1( trajectories(t).time_forward, trajectories(t).linspeed_forward, clusters(nc).timestamp(idx_forward), 'nearest' );
        speed_back = interp1( trajectories(t).time_back, trajectories(t).linspeed_back, clusters(nc).timestamp(idx_back), 'nearest' );
        
        %filter velocity
        vel_idx_forward = idx_forward( find( speed_forward >= speed_threshold ) );
        vel_idx_back = idx_back( find( speed_back >= speed_threshold ) );
        
        %linearize position
        linpos_forward = trajectories(t).linearize( clusters(nc).headpos(vel_idx_forward,:) );
        linpos_back = trajectories(t).linearize( clusters(nc).headpos(vel_idx_back,:) );

        %mean rate combined in forward and back laps
        mean_rate(nc,t) = ( numel(linpos_forward) + numel(linpos_back) ) ./ ( sum( diff( trajectories(t).laps_forward, 1, 2) ) + sum( diff( trajectories(t).laps_back, 1, 2) ) );
        fprintf([' mean rate: ' num2str(mean_rate(nc)) '\n'] );
        
        %calculate densities
        bandwidth = 1;                
       
        K_forward = Fs_tracker.*numel( linpos_forward )./numel( trajectories(t).linpos_forward(forward_idx_pos) );
        spike_density_forward = @(x) ksdensity(linpos_forward, x, 'width', bandwidth);
        occupancy_density_forward = @(x) ksdensity( trajectories(t).linpos_forward(forward_idx_pos), x, 'width', bandwidth);
        
        K_back = Fs_tracker.*numel(linpos_back)./numel(trajectories(t).linpos_back(back_idx_pos));
        spike_density_back = @(x) ksdensity( linpos_back, x, 'width', bandwidth);
        occupancy_density_back = @(x) ksdensity( trajectories(t).linpos_back(back_idx_pos), x, 'width', bandwidth);
        
        K_all = Fs_tracker.*( numel(linpos_back) + numel(linpos_forward) )./( numel(back_idx_pos) + numel(forward_idx_pos) );
        spike_density_all = @(x) ksdensity( [linpos_back; linpos_forward], x, 'width', bandwidth);
        occupancy_density_all = @(x) ksdensity( [trajectories(t).linpos_back(back_idx_pos) ; trajectories(t).linpos_forward(forward_idx_pos)], x, 'width', bandwidth);
                
        
        %plot densities
        x_values = linspace(0,length(trajectories(t).traject),100);
        
        axes(h(nc,1+(t-1)*3+2));
        hold on;
        
        d = K_forward.*spike_density_forward(x_values)./occupancy_density_forward(x_values);
        fill( [0 x_values length(trajectories(t).traject)], [0 d 0], [0 0 1], 'FaceAlpha', 0.3);            
        m = max( 1.1*max( d ), 10 );

        d = K_back.*spike_density_back(x_values)./occupancy_density_back(x_values);
        fill( [0 x_values length(trajectories(t).traject)], [0 -d 0], [1 0 0], 'FaceAlpha', 0.3);        
       
        m = max( m, 1.1.*max( d ) );
        
        set( h(nc,1+(t-1)*3+2), 'YLim', [-m m], 'XLim', [0 length(trajectories(t).traject)] );
        
        text( length(trajectories(t).traject)./2, 0.95.*m, 'forward \rightarrow', 'Color', [0 0 1], 'HorizontalALignment', 'center', 'VerticalAlignment', 'top');
        text( length(trajectories(t).traject)./2, -0.95.*m, '\leftarrow back', 'Color', [1 0 0], 'HorizontalALignment', 'center', 'VerticalAlignment', 'bottom');
        
        
        axes(h(nc,1+(t-1)*3+1));
        hold on;
        
        d = K_all.*spike_density_all(x_values)./occupancy_density_all(x_values);
        fill( [0 x_values length(trajectories(t).traject)], [0 d 0], [0 0 0], 'FaceAlpha', 0.3);        
           
        m = max( 10, 1.1*max(d) );
        
        set( h(nc,1+(t-1)*3+1), 'YLim', [0 m], 'XLim', [0 length(trajectories(t).traject)] );       
        
        
        
        %find peak firing rate
        %[peak_pos(nc) peak_val(nc)] = patternsearch( @(x) -K_all.*spike_density_all(x)./occupancy_density_all(x), length(trajectories(t).traject)/2, [], [], [], [], 0, length(trajectories(t).traject), psoptimset('SearchMethod', {@searchga, 1, gaoptimset('Display', 'off')}, 'CompletePoll', 'on', 'Display', 'off') );
        
        x_values = linspace(0,length(trajectories(t).traject),5000);
        d_sample = K_all.*spike_density_all(x_values)./occupancy_density_all(x_values);
        [peak_val(nc) peak_pos(nc)] = max( d_sample );
        peak_pos(nc) = x_values(peak_pos(nc));
            
        %compute spatial information
        %si(nc,t) = spatialinfo( spike_density_all, occupancy_density_all, [0 length(trajectories(t).traject)]);
        %fprintf([' spatial information: ' num2str(si(nc,t)) '\n'] );
        
        
        %continue
        
        
        if 1 %abs(peak_val(nc))>=5 && si(nc,t)>0.5
            line( peak_pos(nc), peak_val(nc), 'Marker', 'o', 'MarkerEdgeColor', [1 0 0], 'MarkerFaceColor', [1 0 0], 'MarkerSize', 3);
            % find place field width
            %first sample density function - 1Hz and find zero crossings
            
            threshold = max( 1, 0.1*peak_val(nc) );
            
            [zc_pn zc_np] = zerocrossing( d_sample-threshold );
            zc_pn = x_values( round( zc_pn ) ) - peak_pos(nc);
            zc_np = peak_pos(nc) - x_values( round( zc_np ) );
            zc_pn = min( zc_pn( zc_pn>0 ) );
            zc_np = min( zc_np( zc_np>0 ) );
            
            if isempty( zc_pn ), zc_pn = length(trajectories(t).traject) - peak_pos(nc); end
            if isempty( zc_np ), zc_np = peak_pos(nc); end
            
            %br = fzero( @(x) K_all.*spike_density_all(x)./occupancy_density_all(x)-1, [peak_pos(c) length(trajectories(t).traject)] );
            %if isnan(br), br = length(trajectories(t).traject); end
            %bl = fzero( @(x) K_all.*spike_density_all(x)./occupancy_density_all(x)-1, [0 peak_pos(c)] );
            %if isnan(bl), bl = 0; end
            
            line( peak_pos(nc) + [zc_pn zc_pn], [0 10], 'Color', [1 0 0]);
            line( peak_pos(nc) - [zc_np zc_np], [0 10], 'Color', [1 0 0]);
        
            
            tmp = applyfcn( idx_forward_laps, @(idx) trajectories(t).linearize( clusters(nc).headpos(idx,:) ) );
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', [0:numel(tmp)-1], 'Color', [0.7 0.7 1], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);
            [dummy, dummy, tmp] = seg_select( trajectories(t).laps_forward, clusters(nc).timestamp(vel_idx_forward), linpos_forward);
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', [0:numel(tmp)-1], 'Color', [0 0 1], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);

            %lap-based analysis
            nactive = 0;
            for L = 1:numel(idx_forward_laps)
                %find linpos of all spikes in place field
                field_com_forward(t,nc,L) = NaN;
                field_width_forward(t,nc,L) = NaN;
                tmp{L} = tmp{L} - peak_pos(nc);
                valid_spikes = find( tmp{L}>=-zc_np & tmp{L}<=zc_pn );
                if numel(valid_spikes)>1
                    field_com_forward(t,nc,L) = mean( tmp{L}( valid_spikes ) );
                    field_width_forward(t,nc,L) = diff( tmp{L}(valid_spikes([1 end])) );
                end
                if numel(valid_spikes)>0
                    nactive = nactive+1;
                end
            end
            
            active_lap_forward(nc) = nactive ./ numel(idx_forward_laps);
            
            tmp = applyfcn( idx_back_laps, @(idx) trajectories(t).linearize( clusters(nc).headpos(idx,:) ) );
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', -[1:numel(tmp)], 'Color', [1 0.7 0.7], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);
            [dummy, dummy, tmp] = seg_select( trajectories(t).laps_back, clusters(nc).timestamp(vel_idx_back), linpos_back);
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', -[1:numel(tmp)], 'Color', [1 0 0], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);        
            
            set( h(nc,1+(t-1)*3+3), 'YLim', [-numel(idx_back_laps) numel(idx_forward_laps)]);
            
            %lap-based analysis
            nactive = 0;
            for L = 1:numel(idx_back_laps)
                %find linpos of all spikes in place field
                field_com_back(t,nc,L) = NaN;
                field_width_back(t,nc,L) = NaN;
                tmp{L} = tmp{L} - peak_pos(nc);
                valid_spikes = find( tmp{L}>=-zc_np & tmp{L}<=zc_pn );
                if numel(valid_spikes)>1
                    field_com_back(t,nc,L) = mean( tmp{L}( valid_spikes ) );
                    field_width_back(t,nc,L) = diff( tmp{L}(valid_spikes([1 end])) );
                end   
                if numel(valid_spikes)>0
                    nactive = nactive+1;
                end
            end

            active_lap_back(nc) = nactive ./ numel(idx_back_laps);
            
        else
            
            tmp = applyfcn( idx_forward_laps, @(idx) trajectories(t).linearize( clusters(nc).headpos(idx,:) ) );
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', [0:numel(tmp)-1], 'Color', [0.7 0.7 1], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);
            [dummy, dummy, tmp] = seg_select( trajectories(t).laps_forward, clusters(nc).timestamp(vel_idx_forward), linpos_forward);
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', [0:numel(tmp)-1], 'Color', [0 0 1], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);
                        
            tmp = applyfcn( idx_back_laps, @(idx) trajectories(t).linearize( clusters(nc).headpos(idx,:) ) );
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', -[1:numel(tmp)], 'Color', [1 0.7 0.7], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);
            [dummy, dummy, tmp] = seg_select( trajectories(t).laps_back, clusters(nc).timestamp(vel_idx_back), linpos_back);
            event_plot( tmp, 'Axis', h(nc,1+(t-1)*3+3), 'YOffset', -[1:numel(tmp)], 'Color', [1 0 0], 'XLim', [0 length(trajectories(t).traject)], 'SymbolSize', 1);        
                       
            set( h(nc,1+(t-1)*3+3), 'YLim', [-numel(idx_back_laps) numel(idx_forward_laps)]);
            
        end

                
        mean_distance_to_center(nc,t) = mean( abs( [linpos_back ; linpos_forward] - length(trajectories(t).traject)./2 ) );
        mean_rate_forward(nc,t) = numel(linpos_forward) ./ ( sum( diff( trajectories(t).laps_forward, 1, 2) ) );
        mean_rate_back(nc,t) = numel(linpos_back) ./ ( sum( diff( trajectories(t).laps_back, 1, 2) ) );

        n_vel_high = (numel(vel_idx_forward) + numel(vel_idx_back));
        n_vel_low = (numel(idx_forward) + numel(vel_idx_back)) - n_vel_high;
        np_vel_high = numel(forward_idx_pos) + numel(back_idx_pos);
        np_vel_low = numel( trajectories(t).linspeed_forward ) + numel( trajectories(t).linspeed_back) - np_vel_high;
        %speed_pref(nc) = n_vel_high ./ (n_vel_high + (np_vel_high./np_vel_low).*n_vel_low);
        
%         mean_speed(c) = mean( selvel );
%         
%         vel_threshold = 2;
%         
%         n_vel_high = numel( find( selvel>=vel_threshold ) );
%         n_vel_low = numel( find( selvel<vel_threshold ) );
%         A = numel( find( abs(trajectories(t).velocity)>=vel_threshold ) ) ./ numel( find( abs(trajectories(t).velocity)<vel_threshold ) );
%         speed_pref(c) = n_vel_high ./ ( n_vel_high + A.*n_vel_low );
        

    end

    %calculate parameters (i.e. spatial information, mean rate, mean distance
    %to track center, directionality, complex spike index, speed preference,
    %place field yes/no

    
    
end

% mean_distance_to_center
% mean_rate_forward
% mean_rate_back
directionality = (mean_rate_forward - mean_rate_back) ./ (mean_rate_forward + mean_rate_back);

% speed_pref
% [peak_pos' peak_val']
%[mean_rate si]

if nargout>0
    varargout{1} = struct( 'zc_pn', zc_pn, 'zc_np', zc_np, 'peak_pos', peak_pos, 'peak_rate', peak_val, 'directionality', directionality, 'field_com_forward', field_com_forward, 'field_com_back', field_com_back, 'field_width_forward', field_width_forward, 'field_width_back', field_width_back, 'active_lap_forward', active_lap_forward, 'active_lap_back', active_lap_back);
end

%==========================================================================


%print figures
valid_handle = @(h) h( ~isnan(h) & ishandle(h) );

hh = get( valid_handle(h(:,2:end)), 'xlabel' );
if iscell(hh), hh = cell2mat(hh); end
set( hh, 'string', 'cm' );
for k=1:numel(trajectories)
    hh = get( valid_handle(h(:,[1:2].*k+1)), 'ylabel'); if iscell(hh), hh = cell2mat(hh); end
    set( hh, 'string', 'Hz' );
    hh = get( valid_handle(h(:,3*k+1)), 'ylabel'); if iscell(hh), hh = cell2mat(hh); end
    set( hh, 'string', 'lap' );
end

set( f, 'PaperPosition', [0.25 0.25 8 10.5] );

for k=f
    %print(k, '-dpsc', '-Psnare');
end

%close(f);
