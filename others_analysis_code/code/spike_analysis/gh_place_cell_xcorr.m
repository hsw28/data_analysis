function xcorr = gh_place_cell_xcorr(sdat,pos,varargin)

p = inputParser();
p.addParamValue('dt',0.01,@isreal);
p.addParamValue('n_shift',101,@(x) (mod(x,2)==1));
p.addParamValue('smooth_xcorr_kernel_width',[],@isreal);
p.addParamValue('smooth_rate_kernel_width',[],@isreal);
p.addParamValue('run_direction','outbound',@ischar);
p.parse(varargin{:});
opt = p.Results;

[tmp rates_cdat] = assign_rate_by_time(sdat,'timewin',[min(pos.timestamp) max(pos.timestamp)],'samplerate',1/opt.dt);

n_cell = size(rates_cdat.data,2);
n_timebin = size(rates_cdat.data,1);

timebin_centers = conttimestamp(rates_cdat);

if(strcmp(opt.run_direction,'outbound'))
    [times, logicals] = gh_times_in_timewins(timebin_centers,pos.out_run_bouts);
elseif(strcmp(opt.run_direction,'inbound'))
    [times, logicals] = gh_times_in_timewins(timebin_centers,pos.in_run_bouts);
else
    warning(['did not recognize run_direction: ', opt.run_direction, '.  Try "outbound" or "inbound" please.']);
end

bins_to_zero = logical(ones(size(logicals)) - logicals);
bins_to_zero = reshape(bins_to_zero,[],1);

rates_cdat.data(repmat(bins_to_zero,1,n_cell)) = 0;

xcorr_values = NaN .* ones(n_cell,n_cell,opt.n_shift);

steps = [(opt.n_shift-1)/(-2):1:(opt.n_shift -1)/2];

for m = 1:n_cell
    for n = m:n_cell
        data_m = rates_cdat.data(:,m);
        data_n = rates_cdat.data(:,n);
        for k = 1:opt.n_shift
            this_data_m = data_m(k:(end-(opt.n_shift-k)));
            this_data_n = data_n((opt.n_shift-1)/2 : (end - (opt.n_shift-1)/2));
            xcorr_values(m,n,k) = corr(this_data_m,this_data_n);
        end
    end
end
            
xcorr.steps = steps;
xcorr.xcorr_values = xcorr_values;