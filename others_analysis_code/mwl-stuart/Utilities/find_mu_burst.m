function [burst_times  low_t high_t]= find_mu_burst(mu_rate, mu_ts,pos, varargin)
% returns a list of frame start and frame stop times, based upon multi-unit
% firing rate and velocity.  
%
%  bin_width and vel_thold can be specified
%  default bin_width is .005 seconds or 5 millieseconds
%  default vel_thold is .025 or 2.5 centemeters a second

args  = struct('max_stop_vel', .025, 'std', 5);

args = parseArgsLite(varargin, args);


stop_thold=args.max_stop_vel;
n_std=args.std;
hasPos = 1;
% filter down mu_rate to stop_times
if isfield(pos,'timestamp')
    vel = interp1(pos.timestamp, pos.lin_vel, mu_ts, 'nearest');
elseif isfield(pos,'ts')
    vel = interp1(pos.ts, pos.lv, mu_ts, 'nearest');
else
    disp(pos);
    warning('No positional information available');
    hasPos = 0;
end
%stop_ind = logical(vel<stop_thold); 
if hasPos==1
    vel(isnan(vel))=0;
    stop_ind = abs(vel)<=stop_thold; %% don't worry about if the animal is stopped or not
else
    stop_ind = true(size(mu_rate));
end

mua = mu_rate(stop_ind);
ts = mu_ts(stop_ind);

mean_mu = mean(mua);
std_mu = std(mua);

low_t = mean_mu;
high_t = mean_mu+(n_std*std_mu);

trigx_seg = logical2seg(ts(:),mua>=high_t);
meanx_seg = logical2seg(ts,mua>=low_t);

[b n] = inseg(meanx_seg, trigx_seg, 'partial');

burst_times = meanx_seg(logical(n),:);

end




