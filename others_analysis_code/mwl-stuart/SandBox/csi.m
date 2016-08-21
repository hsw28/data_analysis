function [score] = csi(spk_t, spk_h, t_low, t_high)
% CSI Score a list of spikes for fit to a complex-spike burst template
%
%  [score] = csi(spk_t, spk_h, t_low, t_high)
%
%    t_low default: 3ms
%    t_high default: 15ms
%
% Algorithm: Each spike can contribute +1, -1, or 0 to the score, depending
% on whether it matches or doesn't match the template for a complex-spike burst. 
%
% For each spike (except for the first and the last), find its nearest
% neighbor (if pre- and post-intervals are of equal length, use
% post-interval amplitude delta), then assign a score of:
%
%   if nearest spike is < t_low away (within refractory period):
%      -1 
% 
%   if nearest spike is in the burst range (>= t_low & <= t_high away)
%      +1 : if amplitude is decreasing (or equal, and nearest spike is in past )
%      -1 : if amplitude is increasing (or equal, and nearest spike is in future )
%
%   if nearest spike is > t_high away
%       0 
%
% Score is then reported as a percentage of the total # of spikes (can be
% negative).
%
% Should be exactly equivalent to Matt W's csi program (as called by xclust3)
% 
% By: Tom Davidson (tjd@mit.edu)
% $Id: csi.m 450 2007-10-23 16:52:59Z tjd $

if nargin < 4,
  t_high = 0.015; % 15ms in timestamp time
end

if nargin < 3,
  t_low = 0.002; % 2ms  in timestamp time
end

if any(size(spk_t) ~= size(spk_h)) || size(spk_t,2) > 1,
  error('spike times and spike heights must column vectors be of same length');
end

nspks = length(spk_t);

% need 3 spikes for a pre and a post interval
if nspks < 3,
  score = 0;
  return
end

% interspike intervals (ignore first and last spike - as in Matt's csi)
isi_post = diff(spk_t);
isi_pre = isi_post(1:end-1);
isi_post(1) = []; 


% interspike delta_ht % (ignore first and last spike)
isd_post = diff(spk_h);
isd_pre = isd_post(1:end-1);
isd_post(1) = []; 

% is pre-spike interval shorter than post-spike interval?
usepre = isi_pre < isi_post;

% substitute pre interval and delta_ht for those spikes
% (if intervals are equal, use post - as in Matt's csi)
isi = isi_post;
isi(usepre) = isi_pre(usepre);

isd = isd_post;
isd(usepre) = isd_pre(usepre);

% do the scoring (see above for criteria)
score = -sum(isi < t_low) + ...
        sum(isi >= t_low  &  isi <= t_high  &  (isd < 0 | (isd == 0 & usepre))) + ... 
        -sum(isi >= t_low  &  isi <= t_high  &  (isd > 0 | (isd == 0 & ~usepre)));

%       + 0 * sum(isi > t_high)


% report as a %age
score = score / nspks * 100;
