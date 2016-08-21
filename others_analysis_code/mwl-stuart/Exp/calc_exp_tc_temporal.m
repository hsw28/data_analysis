function [cv1 cv2] = calc_exp_tc(spike_times, pos, delta_t, bin_width, s_width, varargin) 
%CALCULATE_TUNING_CURVE
%
%   curve = CALCULATE_TUNING_CURVE(spike_times, animal_pos, dir, fs, )
%
%   curve1 is the place field of movement in the positive direction
%   curve2 is the place field of movement in the negative direction
%   delta_t is 1/Fs or length of one position sample
%
%   bin_width is the width in meters of a single bin of the place field
%size(spike_times)

args.time_win = [-Inf Inf];

args = parseArgsLite(varargin,args);



warning off;
spike_pos = interp1(pos.ts, pos.lp, spike_times, 'nearest');
spike_vel = interp1(pos.ts, pos.lv, spike_times, 'nearest');
warning on;

pos_ind = pos.ts>=args.time_win(1) & pos.ts<=args.time_win(2);
spike_ind = spike_times>=args.time_win(1) & spike_times<=args.time_win(2);

spike_pos = spike_pos(spike_ind);
spike_vel = spike_vel(spike_ind);

%plot(spike_vel)

%pause;
%[size(spike_pos) size(spike_vel)]
spike_pos_dir1 = spike_pos(logical(spike_vel>.10));
spike_pos_dir2 = spike_pos(logical(spike_vel<-.10));


pos_dir1 = pos.lp(pos.lv>.10);
pos_dir2 = pos.lp(pos.lv<-.10);

pos_dir1 = pos_dir1(pos_ind);
pos_dir2 = pos_dir2(pos_ind);

%[sum(pos_dir1) sum(pos_dir2)]

range = min(pos.lp):bin_width:max(pos.lp);
n = length(range);

po1 = histc(pos_dir1, range);
po1 = smoothn(po1, s_width, bin_width);
po2 = histc(pos_dir2, range);
po2 = smoothn(po2, s_width, bin_width);

so1 = histc(spike_pos_dir1, range);
so2 = histc(spike_pos_dir2, range);

warning off;
cv1 = so1 ./(po1 * delta_t);
cv1(isnan(cv1))=0;
cv1(isinf(cv1))=0;
cv1 = cv1+.05;

cv2 = so2 ./(po2 * delta_t);
cv2(isnan(cv2))=0;
cv2(isinf(cv2))=0;
cv2 = cv2+.05;
warning on;
%pause;