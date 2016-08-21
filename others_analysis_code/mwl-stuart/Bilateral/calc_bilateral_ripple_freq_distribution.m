function [results, c, animal] = calc_bilateral_ripple_freq_distribution(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );


[frTrig, frIpsi,  frCont]  = deal( nan(nRipple, 1) );

idx = 1;

for i = 1:nAnimal
    n = numel( ripples(i).meanFreq{1} );
    
    frTrig( idx:idx + n - 1 ) = ripples(i).meanFreq{1};
%     frBaseM( idx:idx + n - 1 ) = ripples(i).peakFrM{1};
    frIpsi( idx:idx + n - 1 ) = ripples(i).meanFreq{2};
%     frIpsiM( idx:idx + n - 1 ) = ripples(i).peakFrM{2};
    frCont( idx:idx + n - 1) = ripples(i).meanFreq{3};
%     frContM( idx:idx + n - 1) = ripples(i).peakFrM{3};
    
    animal(i).trig = ripples(i).meanFreq{1};
    animal(i).ipsi = ripples(i).meanFreq{2};
    animal(i).cont = ripples(i).meanFreq{3};
    
    idx = idx + n;
end

results.trig = frTrig;
results.ipsi = frIpsi;
results.cont = frCont;

nShuffle = 250;


cIpsi = corr(frIpsi, frTrig);
cCont = corr(frCont, frTrig);

[cIpsiShuff, cContShuff] =  deal( nan(250, 1) );

for i = 1:nShuffle
    frShuf = nan * frTrig;
    
    idx = 1;
    for j = 1:nAnimal
        
        nRip = numel(animal(j).trig);
        randIdx = randsample(nRip, nRip, 1);

        frShuf( idx : (idx+nRip-1) ) = animal(j).trig(randIdx);      
        
        idx = idx + nRip;
    
    end
    
    cIpsiShuff(i) = corr(frIpsi, frShuf);
    cContShuff(i) = corr(frCont, frShuf);
    
end

c.ipsi = cIpsi;
c.cont = cCont;
c.ipsiShuf = cIpsiShuff;
c.contShuf = cContShuff;
