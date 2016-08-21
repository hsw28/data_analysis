function save_dataset_file(baseDir, nChan)

MIN_VEL = .05;
MIN_WIDTH = 12;
MIN_AMP = 75;

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

if nargin == 1
    nChan = 4;
end
%% - Save complete data file

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);

if ~exist(dsetFile, 'file')
    
    ep = 'amprun';

    p = load_exp_pos(baseDir, ep);
    
    [ts, waveform, ttList] = load_all_tt_waveforms(baseDir, ep); %#ok ttList saved below

    [amp, width, lp, lv, pc] = deal( repmat({}, numel(ts), 1) );
    
    % Select waveform channels, calc wf peak amp, wf width
    for i = 1:numel(ts)
                
        waveform{i} = waveform{i}(1:nChan,:,:);
        amp{i} = calc_waveform_peak_amp( waveform{i} )';
        width{i} = calc_waveform_width( waveform{i} )';
                
    end
    
    for i = 1:numel(ts)
        t = ts{i};
        
        lp{i} = interp1(p.ts, p.lp, t, 'nearest');
        lv{i} = interp1(p.ts, p.lv, t, 'nearest');
        
        nanIdx = isnan(lv{i}) | isnan(lp{i});
        runIdx = abs(lv{i}) >= MIN_VEL;
        
        wideIdx = mean( width{i} >= MIN_WIDTH, 2 ) >= .5;% Spikes on atleast 1/2 of the channels must be wider than MIN_WIDTH
        ampIdx = max(amp{i},[],2) >= MIN_AMP;
        
        idx = ~nanIdx & runIdx & wideIdx & ampIdx;
        
        ts{i} = ts{i}(idx);
        lp{i} = lp{i}(idx);
        lv{i} = lv{i}(idx);
        
        amp{i} = amp{i}(idx,:);
        width{i} = width{i}(idx);
        waveform{i} = waveform{i}(:,:,idx);
        
        pc{i} = calc_waveform_princom( waveform{i}, nChan );
       
    end
    
    if size(width,2) == size(ts,1)
        width = width';
    end
    
    fprintf('Saving %s\n', dsetFile); 
    save( dsetFile, 'ts', 'lp', 'lv', 'amp', 'width', 'waveform', 'ttList', 'pc');
%     vars = {'ts', 'lp', 'lv', 'amp', 'wide', 'waveform', 'ttList'};
    
%     for iVar = 1:numel(vars)
%         f = sprintf( '%s/dataset_%s.mat', klustDir, vars{iVar} );
%         fprintf('Saving %s\n', f);
%         save(f,  vars{iVar} );
%     end
end








