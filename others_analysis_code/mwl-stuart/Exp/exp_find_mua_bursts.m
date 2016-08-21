function [bursts] = exp_find_mua_bursts(rate, ts, varargin)
%DSET_FIND_MUA_BURSTS - finds burts in the multiunit activity

args = dset_get_standard_args;
args = args.mua_burst;
args = parseArgs(varargin, args);

args.velocity_threshold = .05;
% if no position struct is specified then assume the animal is always stopped
% or if the user specifies to not filter on velocity
if isempty(args.pos_struct) || args.filter_on_velocity == 0 
    vel = 0 .* ts;
else
    vel = interp1(args.pos_struct.ts, args.pos_struct.lv, ts, 'nearest');
end

isStopped = abs( vel ) < args.velocity_threshold;

fprintf('Excluding %d of %d samples during movement\n', nnz(~isStopped), numel(isStopped));
meanMuRate = nanmean( rate(isStopped) );
stdMuRate = nanstd( rate(isStopped) );

rate(~isStopped) = 0;

highThreshold = meanMuRate + stdMuRate * args.high_threshold;
lowThreshold = meanMuRate + stdMuRate * args.low_threshold;

high_seg = logical2seg(ts, rate >= highThreshold);
low_seg =  logical2seg(ts, rate >= lowThreshold);

[~, n] = inseg(low_seg, high_seg);

bursts = low_seg(logical(n), :);

bursts = bursts(diff(bursts,1,2)>args.min_burst_len, :);

end