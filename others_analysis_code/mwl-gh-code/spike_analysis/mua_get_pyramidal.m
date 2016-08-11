function mua = mua_get_pyramidal(mua,varargin)

p = inputParser();
p.addParamValue('t_maxwd_thresh',10);
p.addParamValue('min_amp',250);
p.parse(varargin{:});

n_clust = numel(mua.clust);

if(~isempty(p.Results.min_amp))
    
    for n = 1:n_clust
        the_dat = [sdat_get(mua,n,'t_px'),sdat_get(mua,n,'t_py'),...
            sdat_get(mua,n,'t_pa'),sdat_get(mua,n,'t_pb')];
        keep_ind = max(the_dat,[],2) > p.Results.min_amp;
        mua.clust{n}.data = mua.clust{n}.data(keep_ind,:);
        mua.clust{n}.stimes = mua.clust{n}.stimes(keep_ind');
        mua.clust{n}.nspike = numel(mua.clust{n}.stimes);
    end
    
end

if(~isempty(p.Results.t_maxwd_thresh))
    
    for n = 1:n_clust
        the_dat = sdat_get(mua,n,'t_maxwd');
        keep_ind = the_dat > p.Results.t_maxwd_thresh;
        mua.clust{n}.data = mua.clust{n}.data(keep_ind,:);
        mua.clust{n}.stimes = mua.clust{n}.stimes(keep_ind');
        mua.clust{n}.nspike = numel(mua.clust{n}.stimes);
    end
    
end