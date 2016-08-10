function [mua_p, mua_i] = mua_sort_by_spike_width(mua_sdat, varargin)

p = inputParser();
p.addParamValue('inds_to_plot',[]);
p.addParamValue('i_range',[3 12]);
p.addParamValue('p_range',[15 100]);
p.parse(varargin{:});
opt = p.Results;

mua_p = mua_sdat;
mua_i = mua_sdat;

n_chans = numel(mua_sdat.clust);

spike_width_col = strcmp('t_maxwd', ...
    mua_sdat.clust{1}.featurenames);
spike_time_col = strcmp('time', ...
    mua_sdat.clust{1}.featurenames);

for n = 1:n_chans
    p_bool = and(mua_sdat.clust{n}.data(:,spike_width_col) >= min(opt.p_range),...
                 mua_sdat.clust{n}.data(:,spike_width_col) <= max(opt.p_range));
    i_bool = and(mua_sdat.clust{n}.data(:,spike_width_col) >= min(opt.i_range),...
                 mua_sdat.clust{n}.data(:,spike_width_col) <= max(opt.i_range));
             
    mua_p.clust{n}.data = mua_sdat.clust{n}.data(p_bool,:);
    mua_i.clust{n}.data = mua_sdat.clust{n}.data(i_bool,:);
    
    mua_p.clust{n}.stimes = mua_p.clust{n}.data(:,spike_time_col)';
    mua_i.clust{n}.stimes = mua_i.clust{n}.data(:,spike_time_col)';
    
    mua_p.clust{n}.nspike = numel(mua_p.clust{n}.stimes);
    mua_i.clust{n}.nspike = numel(mua_i.clust{n}.stimes);
    
    mua_p.clust{n}.t_maxwd = mua_p.clust{n}.data(:,spike_width_col)';
    mua_i.clust{n}.t_maxwd = mua_i.clust{n}.data(:,spike_width_col)';
end