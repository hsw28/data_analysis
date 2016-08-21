function [firstTs, spinTs, lastTs, spindleBand] = detect_spindles2(ts, x, varargin)

% Check the inputs
timestampCheck(ts);
Fs = 1 / (ts(2) - ts(1));
ind = 1:numel(ts);

% construct the input arguments
args.band = [7 15];
args.tholdStd = 1.5;
args.eventLen = [.5 2];
args.time_windows = [-inf inf];
args.inter_peak = [1.5 .25];

args = parseArgs(varargin, args);

% filter the input signal in the spindle band
b = make_spindle_filter(Fs, args.band);
spindleBand = filtfilt(b, 1, x);

spindlePow = spindleBand.^2;
thold = mean(spindlePow) + 2 * std(spindlePow);

detector = spindlePow .* double( spindlePow >= thold );

spindleTs = detect_peaks(ts, detector);

dSpinTs = [Inf; diff(spindleTs(:))];

spinStartIdx = dSpinTs >= args.inter_peak(1);
spinEndIdx = dSpinTs >= args.inter_peak(2);


spinOn = 0;

spinTs = nan(size(spindleTs));
firstTs = nan(size(spindleTs));
lastTs = nan(size(spindleTs));

startIdx = 0;
stopIdx = 0;

for i = 1:numel(spindleTs)-1
    if spinOn && spinEndIdx(i+1) == 1
        stopIdx = i;
        spinOn = 0;
    end
    if ~spinOn && spinStartIdx(i) == 1
        startIdx = i;
        spinOn = 1;
    end
    
    if stopIdx>0 && startIdx>0
       dur = spindleTs(stopIdx) - spindleTs(startIdx);
       
       if dur >= args.eventLen(1) && dur < args.eventLen(2)
           spinTs(startIdx:stopIdx) = spindleTs(startIdx:stopIdx);
           firstTs(startIdx) = spindleTs(startIdx);
           lastTs(stopIdx) = spindleTs(stopIdx);
       end
       
       [startIdx, stopIdx] = deal( 0 );
    end
end


spinTs = spinTs( isfinite( spinTs ));
firstTs = firstTs( isfinite( firstTs ));
lastTs = lastTs( isfinite( lastTs ));



    
% 
% 
% 
% 
% 
% 
% 
% 
% % compute the envelope and smooth it
% spindleEnvelope = abs(hilbert(spindleBand));
% k = make_smoothing_kernel(Fs);
% smoothedEnvelope = conv(spindleEnvelope, k, 'same');
% 
% % set samples outside of the desired time_windows to nan
% validSample = seg2binary(args.time_windows, ts);
% windowedEnvelope = smoothedEnvelope;
% windowedEnvelope(~validSample) = nan;
% 
% % Compute the threshold and detect times when the smooth envelope crosses it
% thold = nanmean(windowedEnvelope) + args.tholdStd * nanstd(windowedEnvelope);
% detector = windowedEnvelope > thold;
% detector = [diff(detector); nan];
% 
% % get the first and last indecies of the events that cross the threshold
% tsStart = ind(  detector == 1 );
% tsEnd = ind( detector == -1);
% 
% %construct events, and compute the duration
% events = [tsStart(:), tsEnd(:)];
% duration = diff(events,[],2);
% %divide by Fs to convert from samples to timestamps
% duration = duration / Fs;
% 
% %Filter the events on duration
% validIdx = duration> args.eventLen(1)  & duration< args.eventLen(2);
% events = events(validIdx,:);
% 
% % find the FIRST peak of the spindle oscillation within the spindle window
% getFirstPeak = @(x,y) findpeaks( spindleBand(x:y), 'NPEAKS', 1 );
% [~, peakIdx] = arrayfun(getFirstPeak, events(:,1), events(:,2) );
% peakIdx = peakIdx + events(:,1) - 1;
% 
% % find ALL of the peaks of the spindle oscillation within the spindle window
% getAllPeaks = @(x,y) findpeaks( spindleBand(x:y) );
% [~, allPeaks] = arrayfun(getAllPeaks, events(:,1), events(:,2), 'UniformOutput', 0);
% for i = 1:numel(allPeaks)
%     allPeaks{i} = allPeaks{i} + events(i,1) -1;
% end
% allPeaks = cellfun(@transpose, allPeaks, 'UniformOutput', 0);
% allPeaks = [allPeaks{:}];
% allPeakTs = ts(allPeaks);
% 
% 
% 
% events = ts(events);
% firstPeakTs = ts(peakIdx);

params.bandpass_filter = b;
% params.smoothing_kernel = k;
params.threshold = thold;

end

function b = make_spindle_filter(Fs, freqBand)
    
    n = ceil( 6 * (Fs/freqBand(1)));

    if mod(n,2)
        n = n+1;
    end

    if Fs < 2*freqBand(2)
        error('Cutoff frequency is above the Nyquist limit');
    end
    
    b = fir1(n, 2 * freqBand ./ Fs, blackman(n+1) );
end

function k = make_smoothing_kernel(Fs)

n = round(Fs);
k = normpdf(-n:n, 0, Fs/6);

end
