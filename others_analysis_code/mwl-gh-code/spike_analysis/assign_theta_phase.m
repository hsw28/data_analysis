function new_sdat = assign_theta_phase(sdat,cdat_r,varargin)

p = inputParser();
p.addParamValue('lfp_default_chan','01',@isreal);
p.addParamValue('local_phase',false,@islogical);
p.addParamValue('cdat_chan',[]);
p.addParamValue('verbose',false,@islogical);
p.addParamValue('power_threshold',0,@isreal);
p.addParamValue('featurename','theta_phase');
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

% ******* Now requires sdat_r form (struct w/ fields raw, theta, phase,env) ********

ncell = numel(sdat.clust);



% Build up a bouts cell; one nx2 array for each cdat channel
bouts = cell(size(cdat_r.raw.data,2),1);
if(opt.power_threshold > 0)
    for i = 1:size(cdat_r.raw.data,2)
        bouts{i} = contbouts(contchans(cdat_r.env,'chans',i), 'datargunits','data','thresh',opt.power_threshold);
    end
else
    for i = 1:size(cdat_r.raw.data,2)
        bouts{i} = [cdat_r.raw.tstart, cdat_r.raw.tend];
    end
end


%new_sdat = assign_cdat_to_sdat2(sdat,cdat_r.phase,'bouts',bouts,'cdat_chan',opt.cdat_chan,...
%    'cdat_default_chan',opt.lfp_default_chan,'featurename',opt.featurename);

new_sdat = sdat;

if(opt.draw)
    figure;
end

for n = 1:ncell
    n_features = length(sdat.clust{n}.featurenames);
    phase_col = find(strcmp(sdat.clust{n}.featurenames,'theta_phase'));
    if(isempty(phase_col))
        phase_col = n_features+1;
    end
    lfp_col = [];
    if(opt.local_phase)
        lfp_col = find(strcmp(cdat_r.phase.chanlabels,sdat.clust{n}.comp));
        if(isempty(lfp_col) && ~isempty(opt.cdat_chan))
            lfp_col = find(cdat_r.phase.chanlabels,opt.cdat_chan);
        end
    end
    if(isempty(lfp_col))
        lfp_col = find(strcmp(opt.lfp_default_chan, cdat_r.raw.chanlabels));
    end
    if(~all(size(lfp_col) == [1 1]))
        error('assign_theta_phase:no_good_lfp_column','Could not find the right lfp column.');
    end
    
    phase = cdat_r.phase.data(:,lfp_col)';
    env = cdat_r.env.data(:,lfp_col)';
    ts = conttimestamp(cdat_r.phase);
    
    reset_ind = find((diff(phase) < -3) == 1);
    reset_ind(reset_ind < 3) = [];
    
    y1 = phase(reset_ind - 2);
    y2 = phase(reset_ind - 1);
    x1 = ts(reset_ind - 2);
    x2 = ts(reset_ind - 1);
    
    time_pi = (pi - y1) .* (x2 - x1) ./ (y2 - y1) + x1;
    
    extra_times = [time_pi, time_pi + 1e-5];
    extra_phase = [pi*ones(size(time_pi)), -pi*ones(size(time_pi))];
    
    [ts,a] = sort([ts,extra_times]);
    phase = [phase,extra_phase];
    phase = phase(a);
    
    spike_col = find(strcmp(sdat.clust{n}.featurenames,'time'));
    if(~isempty(spike_col))
        spike_times = sdat.clust{n}.data(:,spike_col);
    else
        spike_times = sdat.clust{n}.stimes;
    end 
    if(isempty(spike_times))
        warning('assign_theta_phase:no_spikes',['Found no spike times for cluster: ', sdat.clust{n}.name]);
    end
    
    
    spike_times(or(spike_times <= cdat_r.phase.tstart, spike_times >= cdat_r.phase.tend)) = NaN;
    isOk = (~isnan(ts)) & (~isnan(phase) & ~isinf(ts) & ~isinf(phase));
    spike_phase = interp1(ts(isOk),unwrap(phase(isOk)),spike_times,'linear','extrap');
    
    [tmp, logicals] = gh_times_in_timewins(spike_times, bouts{lfp_col});
    spike_phase(~logicals) = NaN;
    
    spike_phase = reshape(spike_phase,[],1);
    
    new_sdat.clust{n}.featurenames{phase_col} = 'theta_phase';
    new_sdat.clust{n}.data(:,phase_col) = spike_phase;
    
    if(opt.draw)
        d = cdat_r.theta.data(:,lfp_col)';
        plot(ts, d./(max(d)) + n - 1);
    end
    
end