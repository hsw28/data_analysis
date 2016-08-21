function [results, c, animal] = calc_bilateral_ripple_phase_diff(ripples)

% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );

phase = zeros( nRipple,3 );

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
        
        hil = hilbert(r.rip{i}')';

        % unwrap the phases so we can compute a clean difference in angles
        phs = unwrap( angle(hil) );        
        phs = phs(:, peakIdx);      
        phase(curIdx:(curIdx+nRip-1), i) = phs;       
        
        switch i
            case 1
                animal(iAnimal).trig = [animal(iAnimal).trig phs];
            case 2
                animal(iAnimal).ipsi = [animal(iAnimal).ipsi phs];
            case 3
                animal(iAnimal).cont = [animal(iAnimal).cont phs];
        end
    end
    
    curIdx = curIdx + nRip;
    
end

results.trig = phase(:,1);
results.ipsi = phase(:,2);
results.cont = phase(:,3);

cIpsi = circ_corrcc( phase(:,1), phase(:,2) );
cCont = circ_corrcc( phase(:,1), phase(:,3) );

[cIpsiShuff, cContShuff] =  deal( nan(250, 1) );

nShuffle = 250;
for i = 1:nShuffle
    phShuf = nan * phase(:,1);
    
    idx = 1;
    for j = 1:nAnimal
        
        nRip = numel(animal(j).trig);
        randIdx = randsample(nRip, nRip, 1);

        phShuf( idx : (idx+nRip-1) ) = animal(j).trig(randIdx);      
        
        idx = idx + nRip;
    
    end
    
    cIpsiShuff(i) = circ_corrcc(phase(:,2), phShuf);
    cContShuff(i) = circ_corrcc(phase(:,3), phShuf);
    
end



c.ipsi = cIpsi;
c.cont = cCont;
c.ipsiShuf = cIpsiShuff;
c.contShuf = cContShuff;

end