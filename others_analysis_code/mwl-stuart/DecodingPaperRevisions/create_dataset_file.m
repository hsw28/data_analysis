function create_dataset_file(baseDir, nChan, ts, waveform, ttList, MIN_VEL, MIN_AMP, MIN_WIDTH)
%% Check input arguments
if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('%s is not a string or is not a valid directory', baseDir)
end

if ~isscalar(nChan) || ~isnumeric(nChan) || ~inrange(nChan, [1 4])
    error('nChan must be a numeric scalar between 1 and 4');
end

if ~iscell(ts)
    error('ts must be a cell array of spike times');
end

if ~iscell(waveform)
    error('waveform must be a cell array of waveforms');
end

if ~iscell(ttList)
    error('ttList must be a cell array of strings');
end

if ~isscalar(MIN_VEL) || ~isnumeric(MIN_VEL)
    error('MIN_VEL must be a numeric scalar');
end
if ~isscalar(MIN_AMP) || ~isnumeric(MIN_AMP)
    error('MIN_AMP must be a numeric scalar');
end
if ~isscalar(MIN_WIDTH) || ~isnumeric(MIN_WIDTH)
    error('MIN_WIDTH must be a numeric scalar');
end

%% - Save the dataset file

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);

if ~exist(dsetFile, 'file')
    
    ep = 'amprun';

    p = load_linear_position(baseDir);
    
    nTT = numel(ttList);

    [amp, width, lp, lv, pc] = deal( cell(nTT,1) );
    
    % Select waveform channels, calc wf peak amp, wf width
    for i = 1:nTT
                
        waveform{i} = waveform{i}(1:nChan,:,:);
        amp{i} = calc_waveform_peak_amp( waveform{i} )';
        width{i} = calc_waveform_width( waveform{i} )';
                
    end
    
    for i = 1:nTT
        t = ts{i};
        
        lp{i} = interp1(p.ts, p.lp, t, 'nearest');
        lv{i} = interp1(p.ts, p.lv, t, 'nearest');
        
        nanIdx = isnan(lv{i}) | isnan(lp{i});
        runIdx = abs(lv{i}) >= MIN_VEL;
        
        wideIdx = mean( width{i} >= MIN_WIDTH, 2 ) >= .5;% Spikes on atleast 1/2 of the channels must be wider than MIN_WIDTH
        ampIdx = max(amp{i},[],2) >= MIN_AMP;
        
        idx = ~nanIdx & runIdx & wideIdx & ampIdx;
      
        if nnz(idx) < 10
            idx(idx) = false;
        end
        
        ts{i} = ts{i}(idx);
        lp{i} = lp{i}(idx);
        lv{i} = lv{i}(idx);
        
        amp{i} = amp{i}(idx,:);
        width{i} = width{i}(idx);
        waveform{i} = waveform{i}(:,:,idx);
      
        pc{i} = calc_waveform_princom( waveform{i}, nChan );
       
    end
    
    fprintf('Saving %s\n', dsetFile); 
    save( dsetFile, 'ts', 'lp', 'lv', 'amp', 'width', 'waveform', 'ttList', 'pc');

end








