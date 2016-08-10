function new_sdat = assign_cdat_to_sdat2(sdat,cdat,varargin)

p = inputParser();
p.addParamValue('verbose',false,@islogical);
p.addParamValue('spike_bouts',[]);
p.addParamValue('bouts',[]);
p.addParamValue('featurename','cdat_value',@ischar);
p.addParamValue('cdat_default_chan',[],@isreal);
p.addParamValue('cdat_chan',[]); % this should be 1 by n_clust if anything
p.parse(varargin{:});
opt = p.Results;

nclust = numel(sdat.clust);
nchan = size(cdat.data,2);

cdat_ind_for_sdat = get_cdat_list_for_sdat(sdat,cdat,'cdat_chan',opt.cdat_chan,'cdat_default_chan',opt.cdat_default_chan);

% bouts is a n_chan by 1 cell array of nx2 bout lists, 1 for each cdat chan
if(~iscell(p.Results.bouts))
    bouts = cell(nchan,1);
    bouts{:} = p.Results.bouts;
else
    bouts = p.Results.bouts;
end

if(isempty(cdat_ind_for_sdat))
    warning('some kind of problem: get_cdat_list_for_sdat gives []');
    cdat_ind_for_sdat = ones(nclust);
end

for m = 1:numel(sdat.clust)    
    
    % call all spike values NaN for now
    %stime_ind = find(strcmp(sdat.clust{m}.featurenames,'time'));
    %spike_times = sdat.clust{m}.data(:,stime_ind);
    spike_times = sdat.clust{m}.stimes;

    ctimes = conttimestamp(cdat);
    yi = interp1(ctimes,cdat.data(:,cdat_ind_for_sdat(m))',spike_times);
    
    %[counts,t_ind] = histc(ok_spike_times,ctimes);
    
    %assign vals
    feat_ind = find(strcmp(opt.featurename,sdat.clust{m}.featurenames));
    if(isempty(feat_ind))
        feat_ind = numel(sdat.clust{m}.featurenames) + 1;
    end
    %size(sdat.clust{m}.data)
    %size(yi)
    sdat.clust{m}.data(:,feat_ind) = yi;
    sdat.clust{m}.featurenames{feat_ind} = opt.featurename;
    
    % nan out the parts not in bouts lists
    if(~isempty(p.Results.bouts))
        %bouts{cdat_ind_for_sdat(m)};
        [times, logicals] = gh_times_in_timewins(spike_times,bouts{cdat_ind_for_sdat(m)});
        logicals = logicals';
        sdat.clust{m}.data(logical(1-logicals),feat_ind) = NaN;
    end
end



new_sdat = sdat;
% 