function [results, frBase, frCont, frShuf1, frShuf2] = calc_bilateral_ripple_freq_correlations_mean(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );

% Run the computation
[frBase, frCont, frShuf1]  = deal( nan(nRipple, 1) );

idx = 1;
for i = 1:nAnimal
    n = numel( ripples(i).peakFrM{1} );    
    frBase( idx:idx + n - 1 ) = ripples(i).peakFrM{1};
    frCont( idx:idx + n - 1) = ripples(i).peakFrM{3};
    idx = idx + n;
end

results.rippleFreqCorr = corr2(frBase, frCont);

nShuffle = 500;

results.shuffleFreqCorr = {zeros(nShuffle, 1), zeros(nShuffle, 1) };
disp('starting shuffles')
for sCount = 1:nShuffle
    
    % WITHIN ANIMAL SHUFFLE
    idx = 1;
    for i = 1:nAnimal
        n = numel( ripples(i).peakFrM{1} );
        shuffdIdx = randsample(n, n);
%        frShuf1(idx:idx + n - 1) = ripples(i).peakFrM{1}(shuffdIdx, 1);   
        frShuf1(idx:idx + n - 1) = ripples(i).peakFrM{3}(shuffdIdx, 1);   

        idx = idx + n;
    end

    % BETWEEN ANIMAL SHUFFLE
    %frShuf2 = frBase( randsample(nRipple, nRipple, 1) );
    frShuf2 = frCont( randsample(nRipple, nRipple, 1) );
    
    results.shuffleFreqCorr{1}(sCount) = corr2(frBase, frShuf1);
    results.shuffleFreqCorr{2}(sCount) = corr2(frBase, frShuf2);
    
end
    results.shuffleTypes = {'within', 'between'};

end