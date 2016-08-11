function [grid_data, data_range] = psth_grid(units1,units2,varargin)

p = inputParser();
p.addParamValue('exclude_diagonal',true,@islogical);
p.addParamValue('lag_range',[0.0005 0.002]);
p.addParamValue('lag_range_fn',@mean);
p.parse(varargin{:});
opt = p.Results;

n_units1 = numel(units1.clust);
n_units2 = numel(units2.clust);

grid_data = zeros(n_units1,n_units2);

for nu1 = 1:n_units1
    progress = nu1 / n_units1
    for nu2 = 1:n_units2
        if(~and(nu1 == nu2, opt.exclude_diagonal))
            [this_psth,this_psth_ts] = gh_psth(units1.clust{nu1}.stimes, units2.clust{nu2}.stimes,...
                'return_units','binned_rates','window_length',0.01,'bin_length',0.0004);
            this_ok_log = and( (this_psth_ts >= min(opt.lag_range)), (this_psth_ts <= max(opt.lag_range)) );
            this_val = opt.lag_range_fn(this_psth(this_ok_log));
            grid_data(nu1,nu2) = this_val;
        end
    end
end
        
data_range = [min(min(grid_data)), max(max(grid_data))];