function env = process_trajectories( env, position, extend )
%PROCESS_TRAJECTORIES define linearization functions and find trajectories in data
%
%  env=PROCESS_TRAJECTORIES(env,position) given an environment structure
%  and a position structure, this function will for each trajectory
%  definition:
%   1. create a polyline describing the trajectory
%   2. define linearization and inverse linearization functions
%   3. find the segments in the position data corresponding to
%      trajectories
%   4. extend the segments for as long as the animal is facing the same
%      direction as the end of the trajectory. 
%
%  env=PROCESS_TRAJECTORIES(env,position,0) do not extend trajectories.
%

%  Copyright 2007-2008 Fabian Kloosterman
  
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(extend)
    extend = 1;
end

if isempty(env) || isempty(position)
    %trajectories = [];
    return
end

if isfield( env.definition, 'trajectories')
    
    for tj = 1:numel(env.definition.trajectories)
        
        env.definition.trajectories(tj).name = horzcat( env.definition.trajectories(tj).nodes{:} );
        
        %create polyline describing trajectory
        env.definition.trajectories(tj).traject = create_trajectory( env.definition.trajectories(tj).nodes );
        
        %define linearization function
        if env.definition.trajectories(tj).traject.isspline
            
            tmp = create_linearize_context( 'spline', env.definition.trajectories(tj).traject.vertices, env.definition.trajectories(tj).traject.isclosed);
            for jj=fieldnames(tmp)'
                env.definition.trajectories(tj).(jj{1}) = tmp.(jj{1});
            end
            
        else
            
            tmp = create_linearize_context( 'polyline', env.definition.trajectories(tj).traject.vertices, env.definition.trajectories(tj).traject.isclosed);
            for jj=fieldnames(tmp)'
                env.definition.trajectories(tj).(jj{1}) = tmp.(jj{1});
            end
            
        end
        
        %find trajectory segments
        fn = {env.definition.nodes.name};
        %sc = {env.definition.nodes.nodes};
        for kkk=1:numel(env.definition.nodes)
            sc{kkk} = localrect2coord(env.definition.nodes(kkk));
        end
        [dummy, loc] = ismember( env.definition.trajectories(tj).nodes, fn );
        laps_forward = traject_fcn( position.headpos, sc( loc ), ...
            sc( setdiff(1:numel(fn), loc) ), ...
            0, 0 );
        laps_back = traject_fcn( position.headpos, sc( loc(end:-1:1) ), ...
            sc( setdiff(1:numel(fn), loc) ), ...
            0, 0 );
        
        
        %extend laps
        if (extend)
            vertices = env.definition.trajectories(tj).traject.vertices;
            startrange = atan2( diff( vertices(1:2,2) ), diff( vertices(1:2,1) ) ) + [-0.25 0.25]*pi;
            endrange = atan2( diff( vertices(end-1:end,2) ), diff( vertices(end-1:end,1) ) ) + [-0.25 0.25]*pi;
            laps_forward = extend_trajectory( laps_forward, position.headdir, startrange, endrange );
            laps_back = extend_trajectory( laps_back, position.headdir, endrange+pi, startrange+pi );
        end
        
        env.definition.trajectories(tj).forward.segments = position.timestamp( laps_forward );
        env.definition.trajectories(tj).back.segments = position.timestamp( laps_back );
        
    end

end

switch env.definition.type
    case 'simple track'
        if env.definition.edges(1).isspline
            env.definition.fcn = create_linearize_context( 'spline', env.definition.edges(1).vertices, env.definition.edges(1).isclosed );
        else
            env.definition.fcn = create_linearize_context( 'polyline', env.definition.edges(1).vertices, env.definition.edges(1).isclosed );
        end
    case 'complex track'
        for k=1:numel(env.definition.edges)
            if env.definition.edges(1).isspline
                tmpfcn(k) = create_linearize_context( 'spline', env.definition.edges(k).vertices, env.definition.edges(k).isclosed );
            else
                tmpfcn(k) = create_linearize_context( 'polyline', env.definition.edges(k).vertices, env.definition.edges(k).isclosed );
            end
        end
        env.definition.fcn = create_linearize_context( 'track', tmpfcn );
    case 'circular track'
        env.definition.fcn = create_linearize_context( 'circle', env.definition.edges(1).center, env.definition.edges(1).radius );
    case 'rectangular track'
        val = bsxfun( @times, env.definition.edges(1).size, [-0.5 -0.5; 0.5 -0.5; 0.5 0.5; -0.5 0.5] );
        val = val * [cos(env.definition.edges(1).rotation) -sin(env.definition.edges(1).rotation); sin(env.definition.edges(1).rotation) cos(env.definition.edges(1).rotation)]';
        val = bsxfun( @plus, env.definition.edges(1).center, val );
        env.definition.fcn = create_linearize_context( 'polyline', val, true );
    case 'closed track'
        if env.definition.edges(1).isspline
            env.definition.fcn = create_linearize_context( 'spline', env.definition.edges(1).vertices, env.definition.edges(1).isclosed );
        else
            env.definition.fcn = create_linearize_context( 'polyline', env.definition.edges(1).vertices, env.definition.edges(1).isclosed );
        end
end




  function p=create_trajectory( regions )
  
  if ~all(ismember( regions, {env.definition.nodes.name} ) )
    error('process_trajctories:create_trajectory', 'Unknown regions')
  end
  
  conn = vertcat( env.definition.connections.nodes );
  
  p = struct( 'vertices', zeros(0,2), 'isclosed', strcmp(regions(1),regions(end)), 'isspline', false );
  
  for kk=1:(numel( regions )-1)
    
    do_reverse = false;
    idx = find( strcmp( regions(kk), conn(:,1) ) & ...
                strcmp( regions(kk+1), conn(:,2) ) );
    
    if isempty(idx)
      do_reverse = true;
      idx = find( strcmp( regions(kk), conn(:,2) ) & ...
                  strcmp( regions(kk+1), conn(:,1) ) );
    end
    
    if isempty(idx)
      error(['No polyline connecting ' regions{kk} ' and ' regions{kk+1} '.']);
    end
    
    pidx = env.definition.connections(idx).edge_index;
    
    if do_reverse
      p.vertices = vertcat(p.vertices, flipud( env.definition.edges(pidx).vertices ) );
    else
      p.vertices = vertcat(p.vertices, env.definition.edges(pidx).vertices );
    end
    
    if env.definition.edges(idx).isspline
      p.isspline = true;
    end
    
  end
  
  end


  function trajects = extend_trajectory( trajects, headdir, hd_startrange, hd_endrange)
  
  %find all head directions not within range
  inrange = find( ~circ_inrange( headdir, hd_startrange ) );

  %find nearest not in range head direction sample before start segment
  [np, d] = nearestpoint( trajects(:,1), inrange, 'pre');
  trajects(:,1) = trajects(:,1) - max(0, d(:)-1 );

  %find all head directions not within range
  inrange = find( ~circ_inrange( headdir, hd_endrange ) );

  %find nearest not in range head direction sample after end segment
  [np, d] = nearestpoint( trajects(:,2), inrange, 'post');
  trajects(:,2) = trajects(:,2) + max(0, d(:)-1 );
  
  end

    function val = localrect2coord(r)
         val = bsxfun( @times, r.size, [-0.5 -0.5; 0.5 -0.5; 0.5 0.5; -0.5 0.5] );
         val = val * [cos(r.rotation) -sin(r.rotation); sin(r.rotation) cos(r.rotation)]';
         val = bsxfun( @plus, r.center, val );
    end

end