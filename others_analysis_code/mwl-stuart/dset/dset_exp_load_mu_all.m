function mu = dset_exp_load_mu_all(edir, epoch)
% load a exp as a dset
% DSET
%   - mu
%       - rate
%       - rateL
%       - rateR
%       - timestamps
%       - fs
%       - bursts Nx2

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        CONVERT  MULTI-UNIT ACTIVITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
standardArgs = dset_get_standard_args;
standardArgs = standardArgs.multiunit;

e = exp_load(edir, 'epochs', epoch);

[tt, loc] = load_exp_tt_anatomy(edir);

anat = unique(loc);
muDt = standardArgs.dt;

tbins = e.(epoch).et(1) : muDt : (e.(epoch).et(2)-muDt);

% fprintf('Loading Multiunit...');
anatomy_to_load = {'lCA1', 'rCA1', 'RSC'};

for a = 1:numel(anat)
    
    if all(cellfun( @isempty, strfind(anatomy_to_load, anat{a})))
%         fprintf(' skipping %s', anat{a});
        continue;
    end
    
    ind = strcmp(loc, anat{a});
    
    fprintf('Loading MU from: %s on %d tetrodes\n', anat{a}, nnz(ind));
    [muRate, spikeTimes]= load_mu(edir, epoch, 'ignore_tetrode', tt(~ind) );

    muRate = histc(muRate,tbins);
    mu.ts = tbins;

    if ~isempty(muRate)
        %wave( wave>(mean(wave)+10*std(wave)))=mean(wave);
        mu.(anat{a}) = muRate;
    else
        mu.(anat{a}) = nan;
    end
    
    fld = sprintf('st_%s', anat{a});
    mu.(fld) = spikeTimes;
    mu.fs = muDt^-1;
end

if isfield(mu, 'RSC')
    mu.ctx = mu.RSC;
    mu = rmfield(mu, 'RSC');
end

mu.hpc = mu.rCA1;
mu = rmfield(mu, 'rCA1');

if isfield(mu, 'lCA1')
    mu.hpc = mu.hpc + mu.lCA1;
    mu = rmfield(mu, 'lCA1');
end




if isfield(mu,'hpc')
    mu.hpc = smoothn(mu.hpc, standardArgs.smooth_dt, standardArgs.dt) .* mu.fs;
end

if isfield(mu,'ctx')
    mu.ctx = smoothn(mu.ctx, standardArgs.smooth_dt, standardArgs.dt) .* mu.fs;
end


mu = orderfields(mu);

end

function [mu spikeTimes] = load_mu(edir, ep, varargin)
% load_exp_multiunit(edir, ep, varargin)
% loads the timestamps of all threshold crossing from all tt files
% contained in edir/extracted_data
%
% tetrodes can be flagged as ignored by using the following key value pair:
% 'ignore_tetrode', {'t01', 't02', 't##'}
args.threshold = 0;
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


spikeTimes = {};
for i =1:length(t)
    if ~any( strcmp(loc{i}, {'lCA1', 'rCA1', 'RSC'}) )
%         fprintf('Skipping tetrode in:%s\n', loc{i});
        continue;
    end
    
    if isempty(args.ignore_tetrode) | ~ismember(args.ignore_tetrode, t{i})  %#ok
        file = fullfile(edir, t{i}, [t{i},'.tt']);        

        times = get_spike_times(file, args.threshold);
        spikeTimes{i} = times;
        
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
            fprintf('%s\n', file);

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
        nano_volts = max(double(maxes)/4096.0 * 20 ./gains' * 1e6);

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
    
    
    
    
    