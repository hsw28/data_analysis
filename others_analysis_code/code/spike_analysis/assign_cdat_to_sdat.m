function new_sdat = assign_cdat_to_sdat(sdat,cdat,varargin)

p = inputParser();
p.addParamValue('verbose',false,@islogical);
p.addParamValue('spike_bouts',[]);
p.addParamValue('cdat_bouts',[]);
p.addParamValue('conv_table',[]);
p.addParamValue('featurename','cdat_value',@ischar);
p.addParamValue('cdat_default_chan',[],@isreal);
p.addParamValue('cdat_chan',[]);
p.parse(varargin{:});
opt = p.Results;

nclust = numel(sdat.clust);

cdat_ind_for_sdat = get_cdat_list_for_sdat(sdat,cdat,'cdat_chan',opt.cdat_chan,'cdat_default_chan',opt.cdat_default_chan);
if(isempty(cdat_ind_for_sdat))
    warning('some kind of problem: get_cdat_list_for_sdat gives []');
    cdat_ind_for_sdat = ones(nclust);
end

if(isempty(opt.spike_bouts))
    spike_bout_type = 'none';
else
    if(and(iscell(opt.spike_bouts),numel(opt.spike_bouts)>1))
        spike_bout_type = 'local';
    else
        spike_bout_type = 'global';
        if(not(iscell(opt.spike_bouts)))
            tmp = opt.spike_bouts
            opt.spike_bouts = cell(1);
            opt.spike_bouts{1} = tmp;
        end
    end
end

if(isempty(opt.cdat_bouts))
    cdat_bout_type = 'none';
else
    if(and(iscell(opt.cdat_bouts),numel(opt.cdat_bouts)>1))
        cdat_bout_type = 'local';
    else
        cdat_bout_type = 'global';
        if(not(iscell(opt.cdat_bouts)))
            tmp = opt.cdat_bouts
            opt.cdat_bouts = cell(1);
            opt.cdat_bouts{1} = tmp;
        end
    end
end

for m = 1:nclust
    spike_times = sdat.clust{m}.stimes;
    nspike = numel(spike_times);
    
    this_spike_bouts = [];
    this_cdat_bouts = [];
    
    if(and(strcmp(spike_bout_type,'none'),strcmp(cdat_bout_type,'none')))
        ok_spike_times = spike_times;
        logicals = ones(size(spike_times));
    else
        %figure out this cell's spike_bouts
        if(strcmp(spike_bout_type,'none'))
            this_spike_bouts = [];
        else
            if(strcmp(spike_bout_type,'global'))
                this_spike_bouts = opt.spike_bouts{1};
            else
                this_spike_bouts = opt.spike_bouts{m};
            end
        end
        
        %figure out corresponding cdat's cdat_bouts
        if(strcmp(cdat_bout_type,'none'))
            this_cdat_bouts = [];
        else
            if(strcmp(cdat_bout_type,'global'))
                this_cdat_bouts = opt.cdat_bouts{1};
            else
                this_cdat_bouts = opt.cdat_bouts{cdat_ind_for_sdat(m)};
            end
        end
        this_bouts = gh_bout_intersect(this_spike_bouts,this_cdat_bouts);
        [ok_spike_times,logicals] = gh_times_in_timewins(spike_times,gh_bout_intersect(this_bouts,[cdat.tstart,cdat.tend]));
    end
    
    % call all spike values NaN for now
    values = NaN.*zeros(size(spike_times));
    
%     % look into cdat for values
%     chan_ind = find(strcmp(cdat.chanlabels,sdat.clust{i}.comp));
%     if(isempty(chan_ind))
%         chan_ind = 1;
%     end
    ctimes = conttimestamp(cdat);
    
    yi = interp1(ctimes,cdat.data(:,cdat_ind_for_sdat(m))',spike_times(logical(logicals)),'linear','extrap');
    
    [counts,t_ind] = histc(ok_spike_times,ctimes);
%    i
    %do interpolation calculations
    %dt = 1/cdat.samplerate;
    %size(ok_spike_times)
    %size(ctimes(t_ind)')
    %spike_post_samp = ok_spike_times' - ctimes(t_ind)';
    %low_vals = cdat.data(t_ind,cdat_ind_for_sdat(i));
    %high_vals = cdat.data(t_ind+1,cdat_ind_for_sdat(i));
    %val_difs = high_vals - low_vals;
    %spike_vals = low_vals + spike_post_samp ./ dt .* val_difs;
    
    %assign vals
    feat_ind = find(strcmp(opt.featurename,sdat.clust{m}.featurenames));
    if(isempty(feat_ind))
        feat_ind = numel(sdat.clust{m}.featurenames) + 1;
    end
    values(logical(logicals)) = yi;
    sdat.clust{m}.data(:,feat_ind) = values;
    sdat.clust{m}.featurenames{feat_ind} = opt.featurename;
end

new_sdat = sdat;
% 