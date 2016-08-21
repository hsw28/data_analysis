function result = cluster_theta_analysis( rootdir, epoch, cl_selection, trajects )
  
%import clusters
clusters = import_clusters( fullfile( rootdir, 'epochs', epoch ) );

if nargin<3 || isempty(cl_selection)
  cl_selection = [];
  sel_file = fullfile(rootdir, 'epochs', epoch, 'clusters', 'good_clusters.dat');
  if exist( sel_file, 'file' )
    cl_selection = dlmread( sel_file );
  end
end

if nargin<4 || isempty(trajects)
  trajects = {};
elseif ischar(trajects)
  trajects = {trajects};
end

[nn, edges] = multi_unit_theta_phase( rootdir, epoch, 48 );
[peak,phase_offset] = max( nn );
phase_offset = mean( edges(phase_offset + [0 1]) )


if ~isempty(cl_selection)
  [cl_selection, ia] = intersect( [vertcat(clusters.tetrode) ...
                      vertcat(clusters.cluster_id)], cl_selection, 'rows' ...
                                  );
else
  ia = 1:numel(clusters);
end

result = struct( 'cluster_name', {}, 'tetrode', {}, 'cluster_id', {}, 'n', {},  ...
                 'lap', {}, 'place_field', {}, 'width', {}, 'peak_rate', ...
                 {}, 'mu', {}, 'rbar', {}, 'kappa', {}, 'kuiper', {}, ...
                 'rayleigh', {}, 'slope', {}, 'intercept', {}, 'range', ...
                 {}, 'r', {}, 'regression', {});

for cl_idx = 1:numel(ia)
  cl = ia(cl_idx);
  props = clusters(cl).props();
  
  if isempty(trajects)
    %loop trough all trajectories
    traj = fieldnames( props.trajectories );
  else
    traj = intersect( fieldnames(props.trajectories), trajects );
  end
  
  for t=1:numel(traj)
    
    vel_fltr = abs(props.trajectories.(traj{t}).linvelocity)>=2;

    laps = {'forward','back'};
    
    for L = 1:2
    
      edges = props.trajectories.(traj{t}).(laps{L}).edges;
    
      %loop through all place fields
      n = numel( props.trajectories.(traj{t}).(laps{L}).place_fields );

      for p=1:n
        bnd = props.trajectories.(traj{t}).(laps{L}).place_fields(p).boundary;
        w = diff(bnd);
        idx = find( edges(1:end-1)>=bnd(1) & edges(1:end-1)<bnd(2) );
        m = max( props.trajectories.(traj{t}).(laps{L}).map( idx ) );
      
        if w>=10 && m>=5
          %f = figure;
          %h = axismatrix( 2,2, 'Parent', f );
          %plot_bars( props.trajectories.(traj{t}).(laps{L}).map, 'Edges', ...
          %           props.trajectories.(traj{t}).(laps{L}).edges, 'Parent', ...
          %           h(1,1) );
          %yl = get(h(1,1), 'YLim');
          %line( [bnd(1) bnd(1)], yl, 'Parent', h(1,1), 'Color', [1 0 0]);
          %line( [bnd(2) bnd(2)], yl, 'Parent', h(1,1), 'Color', [1 0 0]);  
          %title( h(1,1), [clusters(cl).name ' - ' traj{t} ' - ' laps{L} ' field=' ...
          %            num2str(p)] );

          
          fltr = props.trajectories.(traj{t}).(laps{L}).place_fields(p).filter ...
                 & props.trajectories.(traj{t}).(laps{L}).filter;
          
          cl_phase = limit2pi( props.theta.phase(fltr) - phase_offset );
          
          %plot( h(2,1), props.trajectories.(traj{t}).linpos(fltr), ...
          %      cl_phase, '.');
          %hold( h(2,1), 'on');
          %plot( h(2,1), props.trajectories.(traj{t}).linpos(fltr), ...
          %      cl_phase+2*pi, '.');
          %set(h(2,1), 'YLim', [0 4*pi]);        
          %line( [bnd(1) bnd(1)], [0 4*pi], 'Parent', h(2,1), 'Color', [1 0 0]);
          %line( [bnd(2) bnd(2)], [0 4*pi], 'Parent', h(2,1), 'Color', [1 0 ...
          %                    0]); 
          [coef, r, func, res] = circ_regression( ...
              props.trajectories.(traj{t}).linpos(fltr)-bnd(1), cl_phase, ...
              [-1 1]*4*pi./w);
          [mu_res, kappa_res] = vonmises_fit( res );
          
          xx = linspace( 0, bnd(2)-bnd(1), 1000 );
          yy = func( xx );
          if coef(2)<0, yy = yy +2*pi; end
          %plot( h(2,1), xx+bnd(1), limit2pi(yy, [0 4*pi]), 'r.' );
          %plot( h(2,1), xx+bnd(1), yy, 'r.' );
          
          %title( h(2,1), ['coef = ' num2str( coef ) ' - r = ' num2str(r) ] );
          
          %linkaxes( h(:,1), 'x');
          
          
          [nn,bins] = phasehist( cl_phase, 24, 'Normalized', 1);
          %ph = polar_axis( h(1,2) );
          %polar_bar( ph, bins(:), nn(:) );
          %polar_set( ph, 'RLim', [0 10*ceil(max(nn)/10)]);
          
          [mu, rbar] = circ_mean( cl_phase );
          [mu, kappa] = vonmises_fit( cl_phase );
          pkuiper = kuiper( cl_phase );
          prayleigh = rayleigh( cl_phase );
          %coef(1) , coef(2), func(bnd(1))
          if strcmp( laps(L), 'forward' )
            intercept = func( xx(1) );
            slope = coef(2);
          else
            intercept = func( xx(end) );
            slope = -coef(2);
          end
          phaserange = abs(diff( func( xx([1 end]) ) ));
          
          result(end+1,1) = struct( 'cluster_name', clusters(cl).name, 'tetrode', clusters(cl).tetrode, 'cluster_id', clusters(cl).cluster_id, 'n', numel(find(fltr)), ...
                 'lap', laps{L}, 'place_field', p, 'width', w, 'peak_rate', m, 'mu', mu, 'rbar', rbar, 'kappa', kappa, 'kuiper', pkuiper, ...
                 'rayleigh', prayleigh, 'slope', slope, 'intercept', intercept , 'range', ...
                 phaserange, 'r', r, 'regression', struct('xx', xx, 'yy', ...
                                                          yy, 'func', func, ...
                                                          'res', res, ...
                                                          'mu_res', mu_res, ...
                                                          'kappa_res', ...
                                                          kappa_res, 'std', ...
                                                          circ_std(res) ) );
        end
      end
    end
  end
end    
    

