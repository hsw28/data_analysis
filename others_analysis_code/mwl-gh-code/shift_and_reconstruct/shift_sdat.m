function new_sdat = shift_sdat(sdat, rat_conv_table, mod_opt, varargin)
% sdat = SHIFT_SDAT(sdat,conv_table,mod_opt,['draw',false])
% Slide spikes forward in backward in time

p = inputParser();
p.addParamValue('compensation',1);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;


% Find the appropriate timeseries to look up into
if(strcmp(mod_opt.shift_by_wave,'none'))
    % In case of no timeshift, we can abort and just return the unshifted clust
    new_sdat = sdat;
    return;
elseif(strcmp(mod_opt.shift_by_wave,'model'))
    if(isempty( mod_opt.modeled_eeg_r ))
        if(isempty (mod_opt.model_params))
            error('shift_sdat:tried_to_model_eeg_but_no_model_params',...
                'Please pass either model_params or modeled_eeg_r to shift_sdat through a spike_mod_opt');
        else
            mod_opt.modeled_eeg_r =  new_eeg_from_model(mod_opt.eeg_r, mod_opt.model_params, rat_conv_table,'place_cells',sdat);
        end
    end
    disp('Using the modeled_eeg_r that was passed in.');
    mod_opt.eeg_to_use = mod_opt.modeled_eeg_r;
elseif(strcmp(mod_opt.shift_by_wave,'phase'))
    mod_opt.eeg_to_use = mod_opt.eeg_r;
end

n_ts = size(mod_opt.eeg_to_use.raw.data,1);
n_chans = size(mod_opt.eeg_to_use.raw.data,2);
mean_phase = gh_circular_mean(mod_opt.eeg_to_use.phase.data,'dim',2);
relative_phase = gh_circular_subtract(mod_opt.eeg_to_use.phase.data, mean_phase);

% If we're using trial-average phase offsets, then find this mean phase
% offset
if(strcmp(mod_opt.shift_timeframe, 'trial_average'))
    trial_avg_phase_offset = gh_circular_mean(relative_phase,'dim',1);
    relative_phase = repmat( trial_avg_phase_offset, n_ts, 1);
end

mod_opt.eeg_to_use.phase.data = relative_phase;

eeg_ts = conttimestamp(mod_opt.eeg_r.raw);
eeg_dt = eeg_ts(2) - eeg_ts(1);
instantaneous_freq = diff([mean_phase; mean_phase(end)]) / eeg_dt / (2*pi);

mod_opt.eeg_to_use.raw.data = mod_opt.eeg_to_use.phase.data ./ (2*pi) ./ (repmat(instantaneous_freq,1,n_chans));

new_sdat = sdat;
new_sdat.clust = cellfun( @(x) lfun_shift_clust(x, rat_conv_table, mod_opt, opt.compensation), sdat.clust,'UniformOutput',false);

if(p.Results.draw)
   for n = 1:numel(sdat.clust) 
       [xs_orig,ys_orig] = gh_raster_points(sdat.clust{n}.stimes);
       [xs_new, ys_new]  = gh_raster_points(new_sdat.clust{n}.stimes);
       plot(xs_orig,ys_orig + n,'b');
       hold on;
       plot(xs_new, ys_new + n, 'g');
   end
end
end


function new_clust = lfun_shift_clust(clust, rat_conv_table, mod_opt, compensation)
    
    new_clust = clust;

    % To what points in time in the model or eeg will each spike look up?
    if(strcmp(mod_opt.shift_timeframe,'single_cycle')) 
        if(isempty(mod_opt.theta_cycle_centers))
            error('lfun_shift_clust:theta_bouts_needed','shift_sdat: mod_opt asked for single_cycle spike shifting, but no theta bout definitons were given');
        end
        sample_times = interp1(mod_opt.theta_cycle_centers, mod_opt.theta_cycle_centers, clust.stimes,'nearest');
    elseif(strcmp(mod_opt.shift_timeframe,'instantaneous'))
        sample_times = clust.stimes;
    elseif(strcmp(mod_opt.shift_timeframe,'trial_average'))
        sample_times = clust.stimes;
    end
    
    
    eeg_trode_match = strcmp(clust.comp, mod_opt.eeg_to_use.raw.chanlabels);
    if(all(eeg_trode_match == 0))
        new_clust = [];
        return;
    end
    %if(sum(eeg_trode_match) > 1)
    %    error('shift_sdat:redundant_eeg_chanlabels',['Trode: ', clust.comp, ' matched multiple eeg chan labels.']);
    %end
    eeg_trode_match = find(eeg_trode_match,1,'first');
    
    this_chan_time_offsets = mod_opt.eeg_to_use.raw.data(:,eeg_trode_match)';
    spike_time_offsets = interp1(conttimestamp(mod_opt.eeg_to_use.raw), this_chan_time_offsets, sample_times);
    
    shift_amount = -1*compensation*spike_time_offsets;
    new_spike_times = clust.stimes + shift_amount;
    
    spike_times_col = strcmp('time', clust.featurenames);
    
    new_clust.stimes = new_spike_times;
    new_clust.data(:,spike_times_col) = new_spike_times';

end