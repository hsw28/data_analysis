function [sources colNames] = dset_load_spike_wave_parameters(animal, day, epoch, electrodeList, varargin)
args = dset_get_standard_args;
args = args.amplitude;
args = parseArgs(varargin, args);

sources = {};

timeRange = dset_load_epoch_times(animal, day, epoch);

for i = 1:numel(electrodeList)
    

paramFile = dset_get_spike_param_file_path(animal, day, epoch, electrodeList(i));
    
    if ~exist(paramFile, 'file')
        continue;
    end
    
    pData = load( paramFile);
    pData = pData.filedata;
    
    data = pData.params(:, 1:6);
    colNames = pData.paramnames(1:6);
    
    % convert from timestamp to seconds
    data(:,1) = data(:,1) / 10000;
    
    % remove spikes from outside the epoch
    idx = data(:,1) >= timeRange(1) & data(:,1) <= timeRange(2);
    data = data(idx,:);
    
    %remove putatitve interneurons
    if args.filter_narrow_spikes == 1
        idx = data(:,6) > args.min_width_threshold_samples;
        data = data(idx,:);
    end
    
    if args.filter_low_amplitude_spikes == 1
       idx = max(data(:,2:5),[], 2)  > args.min_voltage_threshold;
       data = data(idx,:);
    end
    
    sources{i} = data;
end


