function results = calc_ripple_triggered_mean_lfp(ripples)



nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.rip{1},1), ripples, 'UniformOutput', 1) );
nSamp = size(ripples(1).rip{1},2);
[lfpBase, lfpCont]  = deal( nan(nRipple, nSamp) );

idx = 1;
for i = 1:nAnimal
    n = numel( ripples(i).peakFrM{1} );    
    lfpBase( idx:idx + n - 1 , :) = ripples(i).rip{1};
    lfpCont( idx:idx + n - 1 , :) = ripples(i).rip{3};
    idx = idx + n;
end

results.meanLfp{1} = mean(lfpBase);
results.semLfp{1} = std(lfpBase) / sqrt( idx );

results.meanLfp{2} = mean(lfpCont);
results.semLfp{2} = std(lfpBase) / sqrt( idx );

results.ts = ( ( 1:nSamp ) - round( mean( nSamp/2 ) ) ) / ripples(1).fs;


end
