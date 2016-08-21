function process_cluster_theta( rootdir, epoch, varargin )
%PROCESS_CLUSTER_THETA assign theta amplitude/phase to cluster timestamps
%
%  PROCESS_CLUSTER_THETA(rootdir,epoch) assign theta amplitude and phase
%  to spikes in all clusters for the specified epoch. For each cluster,
%  the theta signal from the corresponding tetrode is used.
%
%  PROCESS_CLUSTER_THETA(rootdir,epoch,parm1,val1,...) specifies
%  additional options. Valid options are:
%   theta_source - Inf=find signal with highest theta power, 0=use signal of
%            tetrode the cluster is from, 1..n=use the signal from the
%            source with this number (default=0)
%   propname - name under which the porperty is saved (default=theta)
%   eeg_selection - options for select_eeg function to select a subset of
%                   eeg signals
%  Other parameter/value pairs can be used to select a subset of
%  clusters and are passed directly to the select_cluster function
%

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end
%---VERBOSE---

options = struct( 'theta_source', 0, 'propname', 'theta', 'eeg_selection', {{}} );
[options, remainder] = parseArgs( varargin, options );

%import tetrode_info
tetrode_info = import_tetrode_info( rootdir );
%import clusters
clusters = import_clusters( fullfile( rootdir, 'epochs', epoch ), tetrode_info );
%import eeg
eeg = import_eeg( rootdir, epoch );

cl_idx = select_cluster(clusters, remainder{:} );
if isempty(cl_idx)
  verbosemsg('No clusters to be processed...abort');  
  return
end

eeg_idx = select_eeg( eeg, options.eeg_selection{:} );
if isempty(eeg_idx)
  verbosemsg('No eeg signals...abort')
  return
end

if isinf(options.theta_source) %find signal with max theta power in eeg signal
                         %selection
  verbosemsg('Searching for signal with highest theta power...');
  mean_theta_power = 0;
  signal_id = [];
  for k=eeg_idx
    props = eeg(k).props('theta');
    if isempty(props)
      continue
    end
    tmp = mean(abs(props.theta.hilbert.transform));
    if tmp > mean_theta_power
      mean_theta_power = tmp;
      signal_id = k;
    end
  end
  if isempty(signal_id)
    verbosemsg('No signal with theta...abort')
    return
  end
  signal = eeg(signal_id);
  props = signal.props('theta');  
elseif options.theta_source>0 %find specified signal
  idx = find( [eeg.source]==options.theta_source);
  if numel(idx)~=1
    verbosemsg('Cannot find eeg signal...abort')
    return
  end
  signal = eeg(idx);
  props = signal.props('theta');
  if isempty(props)
    verbosemsg('Signal has no theta...abort')
    return
  end
end

for k=cl_idx(:)'
  
  tetrode_id = find( [tetrode_info.id]==clusters(k).tetrode );
  
  if options.theta_source==0
    signal = find_signal( eeg, tetrode_info(tetrode_id).source);
    if isempty(signal)
      verbosemsg(['Skipping cluster ' num2str(k) ' ...no eeg signal...abort'])
      continue
    end
    props = signal.props('theta');    
    if isempty(props)
      verbosemsg(['Skipping cluster ' num2str(k) ' ...no theta...abort'])      
      continue
    end
  end
 
  verbosemsg(['Computing theta phase and amplitude for cluster ' num2str(k) ...
             '...'])
  theta_phase = interp1( props.theta.hilbert.time, unwrap( ...
      angle(props.theta.hilbert.transform) ), clusters(k).timestamp );
  theta_amp = interp1( props.theta.hilbert.time, ...
                       abs(props.theta.hilbert.transform), clusters(k).timestamp ...
                       );
  
  verbosemsg('Saving cluster theta...');
  save_props( fullfile( rootdir, 'epochs', epoch, 'clusters'), clusters(k).name, ...
              struct( options.propname, struct( 'created', datestr(now), ...
                                       'signal_source', signal.source, ...
                                       'signal_file', signal.file, ...
                                       'signal_channel', signal.channel, ...
                                       'phase', limit2pi(theta_phase), ...
                                       'amp', theta_amp ) ) );
  
end



function signal = find_signal( eeg, source )

signal = [];

if ~isempty(source) && source~=0
    idx = find( [eeg.source] == source );
    if ~isempty(idx)
        signal = eeg(idx);
        return
    end
end

% $$$ if ~isempty(altsource) && altsource~=0
% $$$     idx = find( [eeg.source] == altsource );
% $$$     if ~isempty(idx)
% $$$         signal = eeg(idx);
% $$$         return
% $$$     end
% $$$ end