function [spikeAmp, spikeTime, spikePos, posGrid, stimTime, stimPos, encoding_segments] = dset_setup_amplitude_decoding_inputs_seperate_trajectories (dset, electrodes, encoding_window)
    
    if ~isfield(dset, 'amp') || ~isfield(dset,'position')
        error('dset variable is not properly initialized');
    end
    
    if nargin==1 || isempty(electrodes)
        electrodes = 1:30;
    end
    
    if nargin<3
        encoding_window = [-inf inf];
    end
    
    amps = dset.amp.amps;
    
    spikeAmp = {};
    spikeTime = {};
    spikePos = {};
    
    trajList = 1 : max( unique( dset.position.trajectory ) );
    for t = trajList
        
        trajIdx = dset.position.trajectory== t;
        
        for e = electrodes
            if e>numel(amps) || isempty(amps{e}) || size(amps{e},1)<50
                continue;
            end
            spikeAmp{e} = amps{e}(:,2:5);
            spikeTime{e} = amps{e}(:,1);
            spikePos{e} = interp1(dset.position.ts, dset.position.lindist, spikeTime{e}, 'nearest') - 1;       
            
        end
        
        posGrid{t} = 0:5:max( dset.position.lindist(trajIdx) );
        stimPos{t} = dset.position.lindist(trajIdx);
        stimTime{t} = dset.position.ts(trajIdx);
        
       
        isMoving = abs(dset.position.smooth_vel) > 10;
        
        enc_seg = logical2seg(dset.position.ts, isMoving);
        idx = enc_seg(:,1) >= encoding_window(1) & enc_seg(:,2) <= encoding_window(2);
    
        enc_seg = enc_seg(idx,:);     
        
        trajIdx = interp1(dset.position.ts, dset.position.trajectory, enc_seg(:,1), 'nearest') == t;
        encoding_segments{t} = enc_seg(trajIdx,:);
        
    end
   
end
