function [f] = plot_bilateral_ripple_freq_distribution(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );


[frBase,frBaseM, frCont, frContM]  = deal( nan(nRipple, 1) );

idx = 1;
for i = 1:nAnimal
    n = numel( ripples(i).peakFreq{1} );
    
    frBase( idx:idx + n - 1 ) = ripples(i).peakFreq{1};
    frBaseM( idx:idx + n - 1 ) = ripples(i).peakFrM{1};
    frCont( idx:idx + n - 1) = ripples(i).peakFreq{3};
    frContM( idx:idx + n - 1) = ripples(i).peakFrM{3};
    
    idx = idx + n;
end


figure;
subplot(211);
plot(frBase,frCont,'.');
title('spectrum');


subplot(212);
plot(frBaseM, frContM,'.');
title('Mean Freq');

end