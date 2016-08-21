function [spect, spectWhite, freqs, peakFreq] = calc_ripple_spectrum(ripple, fs)

nTapers = 4;

rippleBand = [125 275];

Hs = spectrum.mtm(nTapers);

hpsd = psd(Hs, ripple, 'Fs', fs);

logFr = log(hpsd.Frequencies);
logSp = log(hpsd.Data);

%remove any invalid data points
badIdx = isinf(logFr) | isnan(logFr);


logFr = logFr(~badIdx);
logSp = logSp(~badIdx);
spect = logSp;

% compute the line needed to "whiten" the spectrum
regIdx = logFr>3;
b = regress(logSp(regIdx), [logFr(regIdx), ones(size(logFr(regIdx)))]);

logSpHat = b(1)*logFr + b(2);
logSpWhite = logSp - logSpHat;

freqIdx = logFr >= log(rippleBand(1)) & logFr <= log (rippleBand(2));
logSpWhite(~freqIdx) = -Inf;
[~, peakIdx] = max(logSpWhite);


spectWhite = exp(logSp - logSpHat); % returned whitened spectrum
freqs = exp(logFr);
peakFreq = freqs(peakIdx);

end