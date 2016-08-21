function [bursts] = find_mua_bursts(mu, varargin)
%DSET_FIND_MUA_BURSTS - finds burts in the multiunit activity

args = dset_get_standard_args;
args = args.mua_burst;
args.min_burst_len = .05;
args.low_threshold = .5;
args.high_threshold = 3.5;
args.fld = 'hpc';

args = parseArgs(varargin, args);


args.velocity_threshold = .025;
% if no position struct is specified then assume the animal is always stopped
% or if the user specifies to not filter on velocity
if isempty(args.pos_struct) || args.filter_on_velocity == 0
    vel = 0.*mu.ts;%isStopped = true(size(mu.ts));
else
    vel = interp1(args.pos_struct.ts, args.pos_struct.lv, mu.ts, 'nearest');
end

isStopped = abs( vel ) < args.velocity_threshold;

% fprintf('Excluding %d of %d samples during movement\n', nnz(~isStopped), numel(isStopped));
meanMuRate = nanmean( mu.(args.fld)(isStopped) );
stdMuRate = nanstd( mu.(args.fld)(isStopped) );


mu.(args.fld)(~isStopped) = 0;

highThreshold = meanMuRate + stdMuRate * args.high_threshold;
lowThreshold = meanMuRate + stdMuRate * args.low_threshold;

high_seg = logical2seg(mu.ts, mu.(args.fld) >= highThreshold);
low_seg =  logical2seg(mu.ts, mu.(args.fld) >= lowThreshold);

[~, n] = inseg(low_seg, high_seg);

bursts = low_seg(logical(n), :);

bursts = bursts(diff(bursts,1,2)>args.min_burst_len, :);

end