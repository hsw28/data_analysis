function [spikes tt_id widths] = load_tt_peak_times(session_dir, varargin)
% creates a tetrode map using position data and spike amplitude
% MAKE_TETRODE_MAP(session_dir, varargin)
% arg pairs:
%   - data_type: (old/new)
%   - pos: position vector (1d)
%   - epoch: epoch to load from

args.epoch = 'invalid_epoch_name';
args.time_range = nan;
args.threshold = 60;
args.max_thold = Inf;
args.scale_amplitudes = 0;
args.scale_fn = @sqrt;
args.idx = [];

args = parseArgsLite(varargin, args);

if ~isa(args.scale_fn, 'function_handle');
    error('Invalid scaling function specified, you must use a valid function handle');
end

if strcmp(args.epoch,'invalid_epoch_name')
    error('You must specify a valid epoch name');
end


    fields = {'timestamp', 'waveform', 'id'};
    [e_name e_times] = load_epochs(session_dir);
    e_ind = find(strcmp(e_name, args.epoch));
    epoch_range = e_times(e_ind,:)*10000;

    if isnan(args.time_range)
        ts = e_times(e_ind,1);
        te = e_times(e_ind,2);
    else
        ts = args.time_range(1);
        te = args.time_range(2);
    end


    if exist(fullfile(session_dir, 'extracted_data'), 'dir')
        tt_files = get_dir_names(fullfile(session_dir, 'extracted_data', '*.tt'));
        for i=1:numel(tt_files)
            tt_files{i} = fullfile(session_dir, 'extracted_data', tt_files{i});
        end
    else
        tt_files_d = dir(fullfile(session_dir, 't*'));
        ind = cell2mat({tt_files_d.isdir});
        tt_files_d = tt_files_d(ind);
        for i = 1:numel(tt_files_d)
            tt_files{i} = fullfile(session_dir, tt_files_d(i).name, [tt_files_d(i).name, '.tt']);
        end
        
    end
        

    
    n_tt = length(tt_files);
    spikes = cell(0);
    tt_id = cell(0);
    widths = cell(0);
    spike_id = cell(0);
    
    if isempty(args.idx)
        args.idx = cell(n_tt,1);
    end
    for n =1:n_tt
        disp([args.epoch, ': Loading data from: ' tt_files{n}]);
        file = tt_files{n};
        [data width ids] = get_spike_data(file, fields, epoch_range, ts ,te, args.threshold, args.max_thold, args.idx{n});

        if (size(data,1)>100);
            if args.scale_amplitudes
                data(:,1:4) = args.scale_fn(data(:,1:4));
            end
            spikes{end+1} = data;
            tt_id{end+1} = file;
            widths{end+1} = width;
            spike_id{end+1} = ids;
     
        end
    end
    %mu.info = fullfile(session_dir, args.epoch);
    disp(['Data loaded from :', num2str(n), ' tetrodes!']);
  
end
function [out width ind] = get_spike_data(file, fields, epoch_range, ts, te, thold, max_thold, idx)
    
    if isempty(idx)
        f = loadrange(mwlopen(file), fields, epoch_range, 'timestamp');
    else
        f = load(mwlopen(file), fields, idx);
    end
    
    warning off;
    ind = f.timestamp<=uint32(te*10000) & f.timestamp>=uint32(ts*10000);
    warning on;
    f.timestamp = f.timestamp(ind);
    f.waveform = f.waveform(:,:,ind);
    
    gains = get_gains(file);    
    
    maxes = max(f.waveform, [], 2);
    maxes = squeeze(maxes);
    gains(gains==0) = inf;
    gains = repmat(gains, length(maxes),1)';
    
    nano_volts = double(maxes)/4096.0 * 10 ./gains * 1e6;

    nano_volts(nano_volts>1000) = 0;
    ind = max(nano_volts)>=thold & max(nano_volts)<max_thold;
    nano_volts = nano_volts(:,ind);
    times = double(f.timestamp(ind))/10000;  

    out = [nano_volts', times(:)];
    
    width = get_spike_width(f.waveform);
    width = width(ind);
    
    ind = find(ind);

end

function w = get_spike_width(wave)
	mw = squeeze(mean(wave));
    [mx mxind] = max(mw(5:12,:));
    mxind = mxind + 4;
    [mx mnind] = min(mw(13:end,:));
    mnind = mnind +12;

    w = (mnind - mxind);% * 3.2e-5;
end


function gains = get_gains(file)

    head = loadheader(file);

    chans = [0 1 2 3];
    if head(1).Probe == 1
        chans = chans+4;
    end

    strA = 'channel ';
    strB = ' ampgain';
    gains = nan(1,4);
    for j=1:length(chans);
        str(j,:) = [strA, num2str(chans(j)), strB];
        gains(j) = str2double(head(2).(str(j,:)));
    end
end        

