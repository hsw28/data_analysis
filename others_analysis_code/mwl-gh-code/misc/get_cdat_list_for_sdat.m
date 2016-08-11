function ind_list = get_cdat_list_for_sdat(sdat,cdat,varargin)

p = inputParser();
p.addParamValue('cdat_chan',[]);
p.addParamValue('cdat_default_chan',1);
p.addParamValue('verbose',false,@islogical);
p.parse(varargin{:});
opt = p.Results;

nclust = sdat.nclust;

% first, build mapping from sdat to cdat chans
if(isempty(cdat.chanlabels))
    warning('cdat had no chanlabels, so all clusts are measured against first cdat series.');
    cdat_ind_for_sdat = ones(1,nclust);
else
    if(isnumeric(opt.cdat_default_chan))
        cdat_default_chan_ind = opt.cdat_default_chan;
    else
        cdat_default_chan_ind = find(strcmp(cdat.chanlabels,opt.cdat_default_chan));
    end
    if(isnumeric(opt.cdat_chan))
        cdat_chan_ind = opt.cdat_chan;
    else
        cdat_chan_ind = find(strcmp(cdat.chanlabels,opt.cdat_chan));
    end
    cdat_default_chan_ind
    cdat_ind_for_sdat = ones(1,nclust) .* cdat_default_chan_ind;
    if(isempty(opt.cdat_chan)) % empty opt.cdat_chan implies use sdat comp for cdat chan, fail to default chan
        for m = 1:nclust
            if(opt.verbose)
                disp(['m: ', num2str(m)]);
                disp(['sdat.clust(m).comp: ', sdat.clust{m}.comp]);
                disp(['cdat.chanlabels{1}: ', cdat.chanlabels{1}]);
            end
            this_cdat_ind = find(strcmp(sdat.clust{m}.comp,cdat.chanlabels));
            disp(['this_cdat_ind: ', num2str(this_cdat_ind)]);
            if(numel(this_cdat_ind) > 1)
                warning(['Found multiple cdat chans with label ', sdat.clust{m}.comp,'.  Using the first one.']);
                this_cdat_ind = this_cdat_ind(1);
            elseif(numel(this_cdat_ind) < 1)
                warning(['Found no cdat chans with label ', sdat.clust{m}.comp,'. Using the first cdat chan.']);
                this_cdat_ind = 1;
            end
            cdat_ind_for_sdat(m) = this_cdat_ind;
        end
    else
        cdat_ind_for_sdat = cdat_chan_ind .* ones(1,nclust);
    end
end
if(opt.verbose)
    for m = 1:nclust
        disp(['sdat.clust{',num2str(m),'}: ', sdat.clust{m}.name,'  comp: ', sdat.clust{m}.name,...
            ' gets cdat(' num2str(cdat_ind_for_sdat(m)),'): ', cdat.chanlabels{sdat_ind_for_sdat(m)}]);
    end
end

ind_list = cdat_ind_for_sdat;