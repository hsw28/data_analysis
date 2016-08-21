function [nn, edges] = multi_unit_theta_phase( rootdir, epoch, varargin )
%MULTI_UNIT_THETA_PHASE
%


options = struct( 'nbins', 24, 'segments', [], 'theta_amp', 0);
[options, remainder] = parseArgs( varargin, options);

%import tetrodes
tetrodes = import_tetrode_info( rootdir );
%import clusters
clusters = import_clusters( fullfile( rootdir, 'epochs', epoch ), tetrodes );

cl_idx = select_cluster(clusters, remainder{:} );
if isempty(cl_idx)
  error('multi_unit_theta_phase:invalidArgument', 'No clusters to be processed'); 
end


phase = [];
n=0;

if nargout==0
  h = axismatrix( numel(cl_idx)+1,1,'YSpacing', 0);
end

edges = linspace(0,2*pi,options.nbins+1);

%loop through all clusters
for k=cl_idx(:)'
  
  %if firingrate( clusters(k).timestamp ) > 10
  %  %do not include interneurons
  %  continue
  %end
  
  %load props
  props = clusters(k).props('theta');

  if ~isempty( options.segments )
    valid = inseg( clusters(k).timestamp, options.segments );
  else
    valid = ones( size( clusters(k).timestamp) );
  end
  
  if options.theta_amp>0
    valid = valid & props.theta.amp>options.theta_amp;
  end
  
  phase = vertcat( phase, props.theta.phase(valid) );      
keyboard  
  n = n + 1;
  if nargout==0  
    axes(h(n));
    nn = histc(props.theta.phase, edges );
    bar(edges,nn,'histc');
  end
end


nn = histc( phase, edges );

if nargout==0
  axes(h(end));
  bar(edges,nn,'histc');
end

