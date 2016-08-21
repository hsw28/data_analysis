function data = spike_ripple_phase(exp, varargin)
    
args = struct(...
    'epochs', {exp.epochs}, ...
    'eeg_ch', 1, ...
    'n_boot', 1000, ...
    'use_multi_unit', 0, ...
    'tmp_data', 0);

args = parseArgs(varargin, args);

%ad_file = exp.(args.epochs{1}).eeg(args.eeg_ch).raw_ad_file);
%temp_file = '/tmp/data.eeg';

%debuffer_eeg_file(ad_file, temp_file, 2000);


for ep = args.epochs
    e = ep{:};
    if args.tmp_data
        if strcmp(e,'midazolam')
            file = '/data/disk1/tmp_data/sl07_06_midazolam_eeg.eeg';
        elseif strcmp(e,'saline')
            file = '/data/disk1/tmp_data/sl07_06_saline_eeg.eeg';
        else
            error('1');
        end
        m = mwlopen(file);
        ch_str = ['channel', num2str(args.eeg_ch)];
        dataIN = load(m, {'timestamp', ch_str});
        fs = 1/1/mean(diff(dataIN.timestamp));
        rip_filt = getfilter(fs, 'ripple', 'win');
        disp([e, ': Filtering for ripples']);
        ripple = filtfilt(rip_filt, 1, single(dataIN.(ch_str)));
        rip_phase = angle(hilbert(ripple));
        eeg_ts = exp.(e).eeg_ts;

        bins = linspace(-1*pi, pi, 36);

        data.(e).data = zeros(length(exp.(e).rip_burst.windows), 36);
        spike_times = [];

        if args.use_multi_unit 
            spike_times = exp.(e).multiunit.spike_times;
        else
            for cell_n = 1:numel(exp.(e).clusters)
                spike_times = [spike_times(:); exp.(e).clusters(cell_n).time(:)];

            end
        end
        spike_phase = interp1(dataIN.timestamp, rip_phase, spike_times);

        disp('iterating through cells and ripple_bursts');
        for win_n = 1:length(exp.(e).rip_burst.windows)
           win = exp.(e).rip_burst.windows(win_n,:);
           ind = spike_times>=win(1) & spike_times<=win(2);
           d = histc(spike_phase(ind), bins);  
           if size(d,1)>size(d,2)
               d = d';
           end
           data.(e).data(win_n,:) = d;
        end
    end
end

for ep = args.epochs
    e = ep{:};
    data.(e).boot = bootstrp(args.n_boot, @sum, data.(e).data);
    data.(e).mean = mean(data.(e).boot);
    data.(e).std =  std(data.(e).boot);

    data.(e).std = data.(e).std / sum(data.(e).mean);
    data.(e).mean = data.(e).mean / sum(data.(e).mean); 
end
