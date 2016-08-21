function [T, WF, ttList] = load_all_tt_waveforms_prefilter(baseDir, MIN_VEL, MIN_AMP, MIN_WIDTH)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must contain the path of a valid directory');
end

if ~isscalar(MIN_VEL) || ~isnumeric(MIN_VEL) || MIN_VEL < 0
    error('MIN_VEL must be a positive numeric scalar');
end

if ~isscalar(MIN_AMP) || ~isnumeric(MIN_AMP) || MIN_AMP < 0
    error('MIN_AMP must be a positive numeric scalar');
end

if ~isscalar(MIN_WIDTH) || ~isnumeric(MIN_WIDTH) || ~inrange(MIN_WIDTH, [1 32])
    error('MIN_WIDTH must be a numeric scalar between 1 and 32');
end


ep = 'amprun';

tt_dir = dir(fullfile(baseDir,'t*'));


nTT = numel(tt_dir);

ttList = cell(nTT, 1);

for i = 1 : nTT
    if tt_dir(i).isdir
        ttFile = sprintf('%s/%s/%s.tt', baseDir, tt_dir(i).name, tt_dir(i).name);
        if exist( ttFile, 'file')
            ttList{i} = tt_dir(i).name;
        end
    end
end

% remove un used cells due created by the dir command above
ttList = ttList( ~cellfun(@isempty, ttList ));
nTT = numel(ttList);

if numel(ttList) == 0
    error('No .tt files found in %s', baseDir);
end

pos = load_linear_position(baseDir);

%out = cell(size(unique({exp.(epoch).cl.tt})));

[en, et] = load_epochs(baseDir);
et = et( strcmp(ep, en), :);

[T, WF] = deal( cell(nTT,1) );

% p = load_exp_pos(edir, epoch);


if ~exist( sprintf('%s/%s/inter', baseDir, 'kKlust') )
    mkdir(sprintf('%s/%s/inter', baseDir, 'kKlust'));
end

fprintf('Saving prefilted tt files:\n');
for i = 1 : nTT
    
    tmpFile = sprintf('%s/%s/inter/%s_%d.mat', baseDir,'kKlust', ttList{i}, i);
    fprintf('\t%s\n', tmpFile);    
    
    if ~exist( tmpFile, 'file')
        
         ttFile = sprintf('%s/%s/%s.tt', baseDir, ttList{i}, ttList{i});

    %     fprintf('\t%s\n', file);
        [waves, ts] = import_waveforms_from_tt_file(ttFile, 'idx',[],'time_range', et);  

        w = calc_waveform_width(waves)';
        a = calc_waveform_peak_amp(waves)';

        % Filter out spikes during pauses in navigation
        lv = interp1(pos.ts, pos.lv, ts, 'nearest');
        isMoving = abs(lv) >= MIN_VEL;

        wideIdx = mean( w >= MIN_WIDTH, 2 ) >= .5;% Spikes on atleast 1/2 of the channels must be wider than MIN_WIDTH
        ampIdx = max( a ,[],2) >= MIN_AMP;

        %Filter out low amplitude, narrow and low velocity spikes
        idx = isMoving & ampIdx' & wideIdx' & ~isnan(isMoving);

        ts = ts(idx);
        waves = waves(:, :, idx);
        save(tmpFile, 'waves', 'ts')
        clear waves ts lv width pkAmp idx;
    end
end 

fprintf('Combining files:\n');
for i = 1 : nTT
    
    tmpFile = sprintf('%s/%s/inter/%s_%d.mat', baseDir,'kKlust', ttList{i}, i);
    fprintf('\t%s\n', tmpFile);
    in = load(tmpFile);
    
    T{i} = in.ts';
    WF{i} = in.waves;
    
end


end



    
    