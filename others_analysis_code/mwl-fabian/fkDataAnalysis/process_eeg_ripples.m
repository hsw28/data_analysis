function process_eeg_ripples( rootdir, epoch, varargin )
%PROCESS_EEG_RIPPLES ripple detection
%
%  PROCESS_EEG_RIPPLES(rootdir,epoch) detect ripples in all eeg signals
%  for the specified epoch. Ripples are detected after the envelope of
%  the eeg signal (hilbert transform on band-pass filtered signal) is
%  passed though a band-pass median filter. Mountains are detected with
%  an upper threshold of 5 times the inter-quartile-range(iqr) + median
%  and a lower threshold of 2*iqr+median.
%
%  PROCESS_EEG_RIPPLES(rootdir,epoch,'threshold',th) specifies the
%  threshold (which is multiplied by the iqr of the filtered envelope)
%  for ripple detection.
%
%  PROCESS_EEG_RIPPLES(rootdir,epoch,param1,val1,...) specifies
%  additional eeg signal selection criteria, which are passed on to the
%  select_eeg function.
%

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end
%---VERBOSE---


if nargin<2
  help(mfilename)
  return
end

options = struct( 'threshold', [2 5], 'filter_method', 'gauss', 'filter', ...
                  0.01, 'threshold_method', 'mean', 'fs', []);
[options, remainder] = parseArgs( varargin, options );

eeg_signals = import_eeg( rootdir, epoch );

idx = select_eeg( eeg_signals, remainder{:} );

if isempty(idx)
  verbosemsg('No signals to be processed...');
  return
end

for k = idx(:)'
  
  %load data
  verbosemsg(['Loading signal ' num2str(k) '...']);
  [data, t] = eeg_signals(k).load();
  
  %filter
  verbosemsg(['Filtering signal ' num2str(k) ' in ripple band...']);  
  [data, filtercmd] = process_eeg_filter( double(data), 'ripple', eeg_signals(k).rate);  

  %resample
  if ~isempty( options.fs)  
    [a,b] = rat( options.fs ./ eeg_signals(k).rate );
    new_rate = eeg_signals(k).rate * a./b;
    verbosemsg(['Resampling signal from ' num2str(eeg_signals(k).rate) ' ' ...
                'to ' num2str(new_rate)  '...']);    
    data = resample( data, a, b );
    t = interp1( (1:numel(t))', t, 1+( 0:(numel(data)-1) )'.*b/a, 'linear', ...
                 'extrap');    
  else
    new_rate = eeg_signals(k).rate;
  end
  
  
  %compute envelope
  verbosemsg('Computing envelope through hilbert transform...')
  h = hilbert( data );
  hphase = angle( h );
  h = abs( h );
  
  %filter envelope
  verbosemsg('Filtering envelope...')
  switch options.filter_method
    case 'gauss'
     %gaussian smoothing
     h = smoothn( h, options.filter, 1./new_rate);
   case 'median'
    %median band-pass filter
    verbosemsg('Median filtering envelope...')
    h = mvprctile( h, options.filter(1), 'dx', 1./new_rate );
    if numel(options.filter)>1
      h = h - mvprctile( h, options.filter(end), 'dx', 1./new_rate);
    end
   case 'filter'
    %fir band pass filter
    %make sure filter order is even
    options.filter_order = options.filter_order + mod(options.filter_order,2);
    b = fir1(options.filter_order, 2*options.filter./new_rate );
    h = filtfilt( b, 1, h );
  end
  
  %determine threshold
  verbosemsg('Determining threshold...')
  %mean threshold
  mn = mean( h );
  stdev = std( h );  
  %median threshold
  md = median( h );
  r = iqr( h ); 
    
  switch options.threshold_method
   case 'median'
    th = options.threshold.*r + md;
    
    verbosemsg(['median envelope=' num2str(md)])
    verbosemsg(['inter-quartile-range envelope=' num2str(r)])
    verbosemsg(['threshold=' num2str(th)])  
   
   otherwise
    th = options.threshold.*stdev + mn;
  
    verbosemsg(['mean envelope=' num2str(mn)])
    verbosemsg(['standard deviation envelope=' num2str(stdev)])
    verbosemsg(['threshold=' num2str(th)])
  
  end
  
  %find peaks
  verbosemsg('Detecting peaks...')  
  pp = find_extremes( t, h );
  validpeaks = pp.amplitude>=th(end);
  pp = struct('time', pp.time(validpeaks), 'amplitude', pp.amplitude(validpeaks));
  
  %find segments
  verbosemsg('Detecting windows...')
  m = detect_mountains( t, h, 'threshold', th );
  
  %find envelope/phase in segments
  seg = seg_select2( m, t, {data h hphase t},1 );
  
  verbosemsg('Saving ripples...');
  save_props( fullfile( rootdir, 'epochs', epoch, 'eeg'), [eeg_signals(k).name '.signal'],...
              struct( 'ripple', struct('filtercmd', filtercmd,...
                                       'Fs', new_rate, ...
                                       'peaks', pp, ...
                                       'filter_method', options.filter_method, ...
                                       'filter', options.filter, ...
                                       'threshold_method', options.threshold_method, ...
                                       'env_mean', mn, ...
                                       'env_std', stdev, ...
                                       'env_median', md, ...
                                       'env_iqr', r, ...
                                       'threshold', th, ...
                                       'windows', struct('segment', mat2cell(m,ones(size(m,1),1),2), ...
                                                    'time', seg{4}, ...
                                                    'ripple', seg{1}, ...
                                                    'amp', seg{2}, ...
                                                    'phase', seg{3}) ) ) );
  
end
  
return

%for each eeg file ...
for k=1:numel(eeg.files)
    
    % open file
    f = mwlopen( eeg.files(k).filename );
    
    % load all eeg data
    data = load(f, 'all');
    
    % prepare data
    idx = [500000:700000];
    t = data.timestamp(idx);
    data = rmfield( data, 'timestamp');
    data = struct2cell( data );
    data = double( horzcat( data{:} ) );
    data = data(idx,:);

    % ica deartefact
    if isfield( eeg.files(k), 'ica') && ~isempty(eeg.files(k).ica.artefacts)
        fprintf('ICA deartefact data...');
        A = eeg.files(k).ica.A;
        A(:,eeg.files(k).ica.artefacts) = 0;
        data = (A*eeg.files(k).ica.W*data')';
        fprintf('Done.\n');
    end

    % get filter 
    [b, eeg.files(k).ripples.filter] = getfilter( eeg.files(k).rate, 'ripple', 'win');

    %for each channel ...
    fprintf('Setting clipped samples to NaN...');
    for c = 1:size(data,2)    
        % set clipped values to NaN
        if isfield( eeg.files(k), 'clip') && ~isempty(eeg.files(k).clip{c})
            [dummy, invalid_idx] = seg_select( eeg.files(k).clip{c}, t, 'all' );
            data(invalid_idx{1},c) = NaN;
        end
    end
    fprintf('Done.\n');
    
    %filter data twice for zero delay
    fprintf('Filtering data in ripple band...');
    data = filter(b,1,data(end:-1:1,:));
    data = filter(b,1,data(end:-1:1,:));
    fprintf('Done.\n');
    
    %for each channel ...
    for c = 1:size(data,2)
        
        fprintf('Finding extremes...')       
        %find_extremes (gradient method)
        [ripples.peaks, ripples.troughs] = find_extremes(t, data(:,c), 'Method', 'localmax');
        fprintf('Done.\n');
        
        [tm, si] = sort([ripples.peaks.time ; ripples.troughs.time]);
        envelope = [ripples.peaks.amplitude ; ripples.troughs.amplitude];
        envelope = envelope(si);
        
        A = @(x) ksdensity( envelope, x, 'width', 1);
        x = linspace( 0, 0.5*max(envelope), 500);
        [M, Mx] = max( A(x) );
        Mx = x(Mx);
        
        threshold_upper = 8.*Mx;
        threshold_lower = 2.*Mx;
        
        [p2n_upper, n2p_upper] = zerocrossing( envelope - threshold_upper );
        [p2n, n2p] = zerocrossing( envelope - threshold_lower );
        ripple_win = seg_filter( event2seg( n2p, p2n ), n2p_upper, 1, Inf);
        
        ripple_win = interp1( 1:numel(tm), tm, ripple_win );
        
        %post processing: ripple windows that have interval<threshold
        %should be combined and delete those that have a duration outside
        %acceptable limits
        
        duration = diff(ripple_win,1,2);
        duration_limits = [0.02 0.1];        
        valid_ripples = find( duration>=duration_limits(1) & duration<=duration_limits(2) );              
        
        fprintf(['Removed ' num2str( numel(duration) - numel(valid_ripples) ) '/' num2str( numel(duration) ) ' ripple windows with a duration < ' num2str( duration_limits(1) ) ' or > ' num2str( duration_limits(2) ) '\n']);
        ripple_win = ripple_win( valid_ripples, : );
        
        interval_threshold = 0.01;
        R = ripple_win';
        R = diff( R(:) );
        R = R(2:2:end);
        combined_segs = find( R<interval_threshold );
        combined_segs = [ripple_win(combined_segs,1) ripple_win(combined_segs+1,2)];
        
        ripple_win = seg_or( ripple_win, combined_segs );
        
        
    end
    
end
        
        
        
        