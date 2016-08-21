function [meanSpec, stdSpec,  freqs, spec] = meanTriggeredSpectrum(trigWin, ts, signal)

Fs = 1 / (ts(2) - ts(1));

nTrigger = size(trigWin,1);

nTapers = 6;

freqs = 1:350;

spec = nan(nTrigger, numel(freqs));

fprintf('computing:');
nTrigger = min(50,nTrigger);
for iTrig = 1:nTrigger;
    
    fprintf('%d ', iTrig);
    if mod(iTrig, 40) == 0  && iTrig ~= nTrigger
        fprintf('\n\t');
    end
    idx = ts >= trigWin(iTrig,1) & ts <= trigWin(iTrig,2); 
    
    hs = spectrum.mtm(nTapers);
    s = psd(hs, signal(idx), 'Fs', Fs, 'FreqPoints', 'User Defined', 'FrequencyVector', freqs, 'SpectrumType', 'twosided');
    
    spec(iTrig,:) = s.Data;
end
fprintf('\n');
     
meanSpec = mean(spec);
stdSpec = std(spec);




