function [meanSpec, stdSpec,  freqs, spec] = meanTriggeredSpectrum(trigWin, ts, signal)

Fs = 1 / (ts(2) - ts(1));

nTrigger = size(trigWin,1);

freqs = 1:350;

spec = nan(nTrigger, numel(freqs));

% fprintf('computing:');
nTrigger = min(20,nTrigger);
parfor iTrig = 1:nTrigger;
    
%     fprintf('%d ', iTrig);
%     if mod(iTrig, 25) == 0  && iTrig ~= nTrigger
%         fprintf('\n\t');
%     end
    idx = ts>= trigWin(iTrig,1) & ts <= trigWin(iTrig,2); 
    s = pwelch(signal(idx), nnz(idx), 0, freqs, Fs);
    
    spec(iTrig,:) = s;
end
% fprintf('\n');
     
meanSpec = mean(spec);
stdSpec = std(spec);




