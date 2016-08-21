function [frames] = find_ctx_frames(mu, varargin)
%DSET_FIND_MUA_BURSTS - finds burts in the multiunit activity

args = dset_get_standard_args;

args.thold_sd = .15;
args.thold_mn = 0;
args.fld = 'ctx';

args = parseArgs(varargin, args);


args.velocity_threshold = 5;

rate = mu.(args.fld);

rate = smoothn(rate, .03, .01);

% if no position struct is specified then assume the animal is always stopped
% or if the user specifies to not filter on velocity
% if isempty(args.pos_struct) || args.filter_on_velocity == 0

vel = 0.*mu.ts;%isStopped = true(size(mu.ts));
% else
%     vel = interp1(args.pos_struct.ts, args.pos_struct.smooth_vel, mu.ts, 'nearest');
% end

isStopped = abs( vel ) < args.velocity_threshold;

% fprintf('Excluding %d of %d samples during movement\n', nnz(~isStopped), numel(isStopped));
stdMuRate = nanstd( rate(isStopped) );
meanMuRate = nanmean( rate );

rate(~isStopped) = 0;

thold =  meanMuRate * args.thold_mn + stdMuRate * args.thold_sd;

frames = logical2seg(mu.ts, rate >= thold);



% bursts = bursts(diff(bursts,1,2)>args.min_burst_len, :);

end