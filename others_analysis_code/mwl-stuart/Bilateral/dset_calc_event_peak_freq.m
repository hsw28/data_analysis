function [peakFreq, logSpec, logFreq] = dset_calc_event_peak_freq(data, firstTs, fs, eventTimes, varargin )
args.nTapers = 6;
args.rippleFreqBand = [125 300];
args.rippleWindow = [-.1 .1];
args.whiten = 1;
args = parseArgs(varargin, args);


dt = 1.0/fs;
ts = firstTs : dt : firstTs + (numel(data)-1 ) * dt;

Hs = spectrum.mtm(args.nTapers);
peakFreq = [];
logSpec = [];
logFreq = [];
for i=1:numel(eventTimes)
   timeWin = eventTimes(i) + args.rippleWindow;
   dataIdx = ts>= timeWin(1) & ts<=timeWin(2);
   if timeWin(2) > max(ts)
       peakFreq(i) = NaN;
       logSpec(:,i) = NaN;
       logFreq(:,i) = NaN;
       continue;
   end
   
   %Calculate the spectrum of the ripple event
   hpsd = psd(Hs, data(dataIdx), 'Fs', fs);
   logFr = log(hpsd.Frequencies);
   logSp = log(hpsd.Data);
   
   %remove any invalid data points
   badIdx = isinf(logFr) | isnan(logFr);
   logFr = logFr(~badIdx);
   logSp = logSp(~badIdx);
   
   % compute the line needed to "whiten" the spectrum
   regIdx = logFr>3;
   b = regress(logSp(regIdx), [logFr(regIdx), ones(size(logFr(regIdx)))]);
   logSpHat = b(1)*logFr + b(2);
   logSpWhite = logSp - logSpHat;
   
   % compute the frequency with the most "power" in the specified frequency range
   freqIdx = logFr >= log(args.rippleFreqBand(1)) & logFr <= log (args.rippleFreqBand(2));
   logSpWhite(~freqIdx) = -Inf;
   [~, peakIdx] = max(logSpWhite);
   peakFreq(i) = exp(logFr(peakIdx));
   logSpec(:,i) = logSp - logSpHat; % returned whitened spectrum
   logFreq(:,i) = logFr;
   
end


end

