
function mu = load_exp_mu(edir, ep, varargin)
% load_exp_multiunit(edir, ep, varargin)
% loads the timestamps of all threshold crossing from all tt files
% contained in edir/extracted_data
%
% tetrodes can be flagged as ignored by using the following key value pair:
% 'ignore_tetrode', {'t01', 't02', 't##'}
args.threshold = 65;
args.ignore_tetrode = {'none'};
args = parseArgsLite(varargin, args);

fields = {'timestamp', 'waveform'};

[e_name, e_times] = load_epochs(edir);

e_ind = find(strcmp(e_name, ep));
epoch_range = e_times(e_ind,:)*10000;

t_start = e_times(e_ind,1);
t_end = e_times(e_ind,2);

t = load_exp_tt_list(edir);
[tt, loc] = load_exp_tt_anatomy(edir);

multi_unit = [];
ignored = 0;


for i =1:length(t)
    if ~any( strcmp(loc{i}, {'lCA1', 'rCA1'}) )
%         fprintf('Skipping tetrode in:%s\n', loc{i});
        continue;
    end
    
    if isempty(args.ignore_tetrode) | ~ismember(args.ignore_tetrode, t{i})  %#ok
        file = fullfile(edir, t{i}, [t{i},'.tt']);        

        times = get_spike_times(file, args.threshold);
       
        
        multi_unit = [multi_unit, times];
        
    else
        ignored = ignored+1;
        %disp(['Ignoring tetrode: ', t{i}])
    end
end
   
    
multi_unit = sort(multi_unit);

hardLim = [3892 4118]; % hard coded times to for a bad segment for spl11d15

if strcmp('/data/spl11/day15', edir)
    fprintf('Filtering out bad time for SPL11 D15\n');
    badIdx = multi_unit >= hardLim(1) & multi_unit <= hardLim(2);
    multi_unit = multi_unit(~badIdx);    
end

mu = single(multi_unit);


%mu.info = fullfile(edir, ep);
%disp(['Multi-unit loaded from :', num2str(i-ignored), ' tetrodes!']);
        
function times = get_spike_times(file, thold)
    
    d = dir(file);
    
    if d.bytes>15*1024^2
        f = loadrange(mwlopen(file), fields, epoch_range, 'timestamp');
        warning off;
        ind = f.timestamp<=uint32(t_end*10000) & f.timestamp>=uint32(t_start*10000);
        warning on;
        f.timestamp = f.timestamp(ind);
        f.waveform = f.waveform(:,:,ind);

        gains = get_gains(file);

        maxes = max(f.waveform, [], 2);
        maxes = reshape(maxes, 4, length(maxes), 1);
        gains = repmat(gains, length(maxes),1);
        nano_volts = max(double(maxes)/4096.0 * 10 ./gains' * 1e6);

        %min(nano_volts)
        times = double(f.timestamp(nano_volts>=thold))/10000;    
    else
        times = [];
    end
end

function gains = get_gains(file)

    head = loadheader(file);

    chans = [0 1 2 3];
    if head(1).Probe
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

end

