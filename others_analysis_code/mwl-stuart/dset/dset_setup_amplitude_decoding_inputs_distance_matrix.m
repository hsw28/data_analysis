function [spikeAmp, spikeTime, spikePos, posGrid, distMatrix, stimTime, stimPos, encoding_segments] = dset_setup_amplidute_decoding_inputs (dset, electrodes, encoding_window)
    
    if ~isfield(dset, 'amp') || ~isfield(dset,'position')
        error('dset variable is not properly initialized');
    end
    
    if nargin==1 || isempty(electrodes)
        electrodes = 1:30;
    end
    
    if nargin<3
        encoding_window = [-inf inf];
    end
    
    distMat = dset.amp.distmat;
    amps = dset.amp.amps;
    
    spikeAmp = {};
    spikeTime = {};
    spikePos = {};
    
    for e = electrodes
        if e>numel(amps) || isempty(amps{e}) || size(amps{e},1)<50
            continue;
        end
        spikeAmp{e} = amps{e}(:,2:5);
        spikeTime{e} = amps{e}(:,1);
        spikePos{e} = interp1(distMat.ts, distMat.positionIdx, spikeTime{e}, 'nearest') - 1;       
    end
    
    posGrid= 1:max(distMat.positionIdx)-1;
    distMatrix{1} = distMat.distMat;
    
    stimTime = distMat.ts;
    stimPos = distMat.positionIdx-1;
    
    
    isMoving = abs(dset.position.smooth_vel) > 10;
    encoding_segments = logical2seg(dset.position.ts, isMoving);
    

    idx = encoding_segments(:,1) >= encoding_window(1) & encoding_segments(:,2) <= encoding_window(2);
    
    encoding_segments = encoding_segments(idx,:);
    
end
