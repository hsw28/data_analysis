function [peakTs, ripWin, ts] = jp_detect_ripples(eeg, channel, varargin)
    
    if ~isscalar(channel) || mod(channel, 1) || channel <= 0
        error('Channel must be an scalar containing an integer greater than 0');
    end
   
    chan = find( str2double( eeg.chanlabels) == channel);
    
    if isempty(chan)
        error('Invalid channel specified:%d Please select a channel contained in eeg.chanlabels', channel);
    end
    
    args.high_thold = 5;
    args.low_thold =  3;
    args.min_burst_len = .025;
    
    args.time_range = [-inf, inf];  % Gross period time in which to find ripples
    args.ignore_seg = []; % specific segments of time to IGNORE when looking for ripples
    args.ts = [];
    
    args = parseArgs(varargin, args);

    data = eeg.data(:, chan);
   
    fprintf('\tfiltering');
    rFilt = getfilter(eeg.samplerate, 'ripple', 'win');
    ripBand = filtfilt(rFilt, 1, data);
    
    fprintf(', computing envelope');
    ripEnv = abs(hilbert( ripBand) );
    
    nSamp = size(data,1);
    
    ind = 1:nSamp;
    ts = eeg.tstart : 1/(eeg.samplerate) : eeg.tend;
    
    if ~isempty( args.ignore_seg) 
        ignoreIdx = seg2binary(args.ignore_seg, ts);
    else
        ignoreIdx = false( size(ripEnv) );
    end
    
    fprintf(', detecting events');
    ignoreIdx(ts < args.time_range(1)) = true;
    ignoreIdx(ts > args.time_range(2)) = true;
     
    tHigh = args.high_thold .* nanstd( ripEnv(~ignoreIdx) );
    tLow = args.low_thold .* nanstd( ripEnv(~ignoreIdx) ); 
    
    ripEnv(ignoreIdx) = 0;

    high_seg = logical2seg( ind, ripEnv >= tHigh );
    low_seg = logical2seg( ind, ripEnv >= tLow );

    % which low segments contain high segments
    [~, n] = inseg(low_seg, high_seg);

    fprintf(', finding peaks');
    % define these low segments as the bursts
    winIdx = low_seg( logical(n), :);
    
    winIdx = winIdx( diff(winIdx,[],2) >= args.min_burst_len * eeg.samplerate, : );

    % find the index of the peak of the rippleband lfp within the window
    findMaxEnvFunc = @(x,y) max( ripBand(x:y) );

    % select the sample in the burst with the largest envelope as the peak
    [~, peakIdx] = arrayfun(findMaxEnvFunc, winIdx(:,1), winIdx(:,2) );

    % correct peakIdx offset
    peakIdx = peakIdx + winIdx(:,1) - 1;

    % remove peaks that are within 500 samples of the beginning or the end
    % of the recording
    validPeaks = peakIdx > 500 & peakIdx < (nSamp - 500);

    
    % remove invalid peaks
    peakIdx = peakIdx(validPeaks);
    winIdx = winIdx(validPeaks,:);  
    
    peakTs = ts(peakIdx);
    ripWin = ts(winIdx);
    
    fprintf(', DONE!\n');
end