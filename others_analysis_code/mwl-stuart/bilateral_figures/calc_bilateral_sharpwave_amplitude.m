function [results, c, animal] = calc_bilateral_sharpwave_amplitude(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );

rAmp = zeros( nRipple,3 );

curIdx = 1;

for iAnimal = 1:nAnimal
    
    r = ripples(iAnimal);
    peakIdx = find(r.window==0) - 1; % correction for bad peak indexing!?!
    nRip = numel(r.peakIdx);
    
    animal(iAnimal).trig = [];
    animal(iAnimal).ipsi = [];
    animal(iAnimal).cont = [];
    
    for i = 1:numel(r.rip)
        if isempty(r.rip{i})
            continue;
        end
        
        
        %%
        sw = r.sw{i};
%         hil = abs( hilbert(r.sw{i}')' );
        baseline = mean( sw(:, 1:5) ,2);
        sw = bsxfun(@minus, sw, baseline);
        sw = sqrt( sw .^2 );
        peakIdx = [200:250];
        swAmp = max(sw(:, peakIdx), [], 2);
        %%   
        
        switch i
            case 1
                animal(iAnimal).trig = [animal(iAnimal).trig swAmp];
            case 2
                animal(iAnimal).ipsi = [animal(iAnimal).ipsi swAmp];
            case 3
                animal(iAnimal).cont = [animal(iAnimal).cont swAmp];
        end
    end
  
    curIdx = curIdx + nRip;

end

results.trig = cell2mat({animal.trig}');
results.ipsi = cell2mat({animal.ipsi}');
results.cont = cell2mat({animal.cont}');

c.ipsi = corr( results.trig, results.ipsi);
c.cont = corr( results.trig, results.cont);


[cIpsiShuff, cContShuff] =  deal( nan(250, 1) );

nShuffle = 250;
for i = 1:nShuffle
    ampShuf = nan( size( results.ipsi));
    
    idx = 1;
    for j = 1:nAnimal
        
        nRip = numel(animal(j).trig);
        randIdx = randsample(nRip, nRip, 1);

        ampShuf( idx : (idx+nRip-1) ) = animal(j).trig(randIdx);      
        
        idx = idx + nRip;
    
    end
    
    cIpsiShuff(i) = corr(results.ipsi, ampShuf);
    cContShuff(i) = corr(results.cont, ampShuf);
    
end

c.ipsiShuf = cIpsiShuff;
c.contShuf = cContShuff;

end