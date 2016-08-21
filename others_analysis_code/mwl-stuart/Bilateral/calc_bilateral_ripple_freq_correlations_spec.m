function [results, frBase, frCont, frShuf1, frShuf2] = calc_bilateral_ripple_freq_correlations_spec(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );


[frBase, frCont, frShuf1]  = deal( nan(nRipple, 1) );

idx = 1;
for i = 1:nAnimal
    n = numel( ripples(i).peakFreq{1} );
    shuffdIdx = randsample(n, n);
    
    frBase( idx:idx + n - 1 ) = ripples(i).peakFreq{1};
    frCont( idx:idx + n - 1) = ripples(i).peakFreq{3};
    
    idx = idx + n;
end

results.rippleFreqCorr = corr2(frBase, frCont);

nShuffle = 100;

results.shuffleFreqCorr = {zeros(nShuffle, 1), zeros(nShuffle, 1) };
disp('starting shuffles')
for sCount = 1:nShuffle
    idx = 1;
    for i = 1:nAnimal
        n = numel( ripples(i).peakFreq{1} );
        shuffdIdx = randsample(n, n);
%         frShuf1(idx:idx + n - 1) = ripples(i).peakFreq{1}(shuffdIdx, 1);   
        frShuf1(idx:idx + n - 1) = ripples(i).peakFreq{3}(shuffdIdx, 1);   

        idx = idx + n;
    end

%     frShuf2 = frBase( randsample(nRipple, nRipple, 1) );
    frShuf2 = frCont( randsample(nRipple, nRipple, 1) );
    
    results.shuffleFreqCorr{1}(sCount) = corr2(frBase, frShuf1);
    results.shuffleFreqCorr{2}(sCount) = corr2(frBase, frShuf2);
    
end
    results.shuffleTypes = {'within', 'between'};






% 
% 
% if ~any( strcmp(epoch, {'run', 'sleep') )
%     error('Invalid epoch');
% end
% 
% eList = dset_list_epochs(epoch);
% 
% nShuffle = 500;
% 
% open_pool();
% 
% 
% for i = 1:size(eList,1)
%     dset = dset_load_all(eList{i,1}, eList{i,2}, eList{i,3});
%     dset = dset_get_ripple_events(dset);
%     
%     for j = 1:numel(dset.eeg)
% 
%         nRip = size(e.rips, 1);
%         [~, ~, fr, ~] = calc_ripple_spectrum(dset.eeg(j).rips(1,:), dset.eeg(j).fs);
%         nFreq = numel(tmp,1);
%         
%         [sp spW]  = deal( zeros(nRip, nFreq) );
%         pkFr = zeros(nRip, 1);
%         
%         parfor k = 1:size(dset.eeg(j).rips,1)
%             [sp(k,:), spw(k,:), ~, pkFr(k)] = calc_ripple_spectrum(dset.eeg(j).rips(k,:), dset.eeg(j).fs);    
%         end
%         
%         eeg.ripSp = sp;
%         eeg.ripSpW = spw;
%         eeg.ripSpFr = fr;
%         eeg.ripPkFr = pkFr;
%         
%     end
%     
%     
%     baseChan = dset.channels.base;
%     ipsiChan = dset.channels.ipsi;
%     contChan = dset.channels.cont;
%     
%     eeg = dset.eeg;
%     
%     
%     
%     peakFreqBase = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, peakTs);
%     peakFreqIpsi = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, peakTs);
%     peakFreqCont = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, peakTs);
%     
%     ipsiCorr = corr2(peakFreqBase, peakFreqIpsi);
%     contCorr = corr2(peakFreqBase, peakFreqCont);
%     %%
%     for i = 1:nShuffle
%         shuffleFreq = randsample(peakFreqBase, numel(peakFreqIpsi), 1);
%         shuffCorr(i) = corr2(peakFreqBase, shuffleFreq);
%     end
%     %%
%     
%     freq.base = peakFreqBase;
%     freq.ipsi = peakFreqIpsi;
%     freq.cont = peakFreqCont;
%     
%     
    
end