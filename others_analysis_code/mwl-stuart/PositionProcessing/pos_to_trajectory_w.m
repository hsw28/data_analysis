function [linpos] = pos_to_trajectory_w(lp, varargin)

args.kernelSizeMs= 100;

c2l = lp.paths.c2l;
c2r = lp.paths.c2r;
l2r = lp.paths.l2r;

c2l = smoothn(c2l, args.kernelSizeMs, 1000/lp.samplerate);
c2r = smoothn(c2r, args.kernelSizeMs, 1000/lp.samplerate);
l2r = smoothn(l2r, args.kernelSizeMs, 1000/lp.samplerate);

linpos = nan(size(c2l));

% Correct the center to right trajectory by appending the right trajectory
% on to the end of the left trajectory
c2r(lp.path_occupancy.r) = c2r(lp.path_occupancy.r)  + lp.segment_lengths.l;

% flip the left hand side of the left 2 right trajectory because it was
% flipped during linearizeation of this segment
l2r_lhs = l2r(lp.path_occupancy.l);
mean_l2r_lhs = nanmean(l2r_lhs);
l2r_lhs = -1 * (l2r_lhs - mean_l2r_lhs)  + mean_l2r_lhs;

l2r_lhs = l2r_lhs;
l2r(lp.path_occupancy.l) = l2r_lhs;

l2r(lp.path_occupancy.l) = l2r(lp.path_occupancy.l) + lp.segment_lengths.c;
l2r(lp.path_occupancy.r) = l2r(lp.path_occupancy.r) + lp.segment_lengths.c;

position_matrix(:,1) = c2l;
position_matrix(:,2) = c2r;
position_matrix(:,3) = l2r;

linpos = max(position_matrix')';

end

