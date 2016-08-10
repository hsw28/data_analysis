function [r_pos_array pos] = decode_rem_time(units,varargin)
% DECODE_REM_TIME - decodes the time within a rem episode
%
% r_pos_array = decode_rem_time(units,varargin)
% Inputs:
% -units: sdat
% -[time_field_width (2)]: width (in sec) of 'time-field' bin
% -[time_field_smooth_sd (1)]: width (in time) to smooth time fields
% -[r_tau (0.25)]: width of decoding timebin

p = inputParser();
p.addParamValue('time_field_width',2);
p.addParamValue('time_field_smooth_sd',0);
p.addParamValue('calc_field_timewin',[]);
p.addParamValue('decode_timewin',[]);
p.addParamValue('r_tau',0.25);
p.addParamValue('f_bins',[]);
p.addParamValue('rate_scale_factor',1);
p.addParamValue('trode_groups',[]);

p.parse(varargin{:});
opt = p.Results;

% first, calculate the place fields
if(~isempty(opt.calc_field_timewin))
    t_calc_start = opt.calc_field_timewin(1);
    t_calc_end = opt.calc_field_timewin(2);
else
    n_clust = length(units.clust);
    time_buffer = 1;
    tstart = zeros(1,n_clust);
    tend = zeros(1,n_clust);
    for n = 1:length(units.clust)
        tstart(n) = min(units.clust{n}.stimes);
        tend(n) = max(units.clust{n}.stimes);
    end
    t_calc_start = min(tstart) - time_buffer;
    t_calc_end = max(tend) + time_buffer;
end

ts = [t_calc_start:opt.time_field_width:t_calc_end];
dt = opt.time_field_width;
dt_pos = 0.01;
ts_pos = [t_calc_start:dt_pos:t_calc_end];
pos.timestamp = ts_pos; % we'll need this 'pseudopos' for gh_decode_pos
pos.occupancy.bidirect = dt_pos .* ones(size(ts_pos));
pos.lin_filt = imcont('timestamp',ts_pos','data',ts_pos');
pos.lin_vel_cdat = imcont('timestamp',ts_pos','data',[0,diff(ts_pos)./dt_pos]');
bin_centers = mean([ts(1:end-1); ts(2:end)],1);
n_clust = length(units.clust);
for n = 1:n_clust
    stimes = units.clust{n}.stimes;
    counts = histc(stimes,ts);
    rates = counts(1:end-1) ./ dt;
    if(opt.time_field_smooth_sd > 0)
        smooth_n_bin = opt.time_field_smooth_sd / dt;
        rates = smoothn(rates,smooth_n_bin).*opt.rate_scale_factor;
    end
    units.clust{n}.field.bin_centers = bin_centers;
    units.clust{n}.field.bidirect_rate = rates;
    units.clust{n}.field.out_rate = rates;
    units.clust{n}.field.in_rate = rates;
end
    
if(isempty(opt.trode_groups))
    r_pos_array = gh_decode_pos(units,pos,'r_tau', opt.r_tau,'f_bins',opt.f_bins);
    r_pos_array.color = [1 1 1];
    r_pos_array.trodes = [];
else
    r_pos_array = decode_pos_with_trode_pos(units,pos,opt.trode_groups,'r_tau',opt.r_tau);
end