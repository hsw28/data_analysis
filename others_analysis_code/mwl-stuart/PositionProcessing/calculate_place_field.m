function [cv1 cv2] = calculate_place_field(spike_times, pos, pbins, delta_t, bin_width, s_width) 
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
warning off;
spike_pos = interp1(pos.timestamp, pos.lin_pos, spike_times, 'nearest');
spike_vel = interp1(pos.timestamp, pos.lin_vel, spike_times, 'nearest');
warning on;
%plot(spike_vel)

%pause;
%[size(spike_pos) size(spike_vel)]
spike_pos_dir1 = spike_pos(logical(spike_vel>.10));
spike_pos_dir2 = spike_pos(logical(spike_vel<-.10));


pos_dir1 = pos.lin_pos(pos.lin_vel>.10);
pos_dir2 = pos.lin_pos(pos.lin_vel<-.10);
%[sum(pos_dir1) sum(pos_dir2)]

range = pbins;
n = length(range);

po1 = histc(pos_dir1, range);
po1 = smoothn(po1, s_width, bin_width);
po2 = histc(pos_dir2, range);
po2 = smoothn(po2, s_width, bin_width);

so1 = histc(spike_pos_dir1, range);
%disp(so1([1:n_trunc n-(n_trunc-1):n]))

%so1([1:n_trunc n-(n_trunc-1):n]) = 0;
%so1 = smoothn(so1, s_width, bin_width);

so2 = histc(spike_pos_dir2, range);
%disp(so2([1:n_trunc n-(n_trunc-1):n]))
%so2([1:n_trunc n-(n_trunc-1):n]) = 0;
%so2 = smoothn(so2, s_width, bin_width);
warning off;
cv1 = so1 ./(po1 * delta_t);
cv1(isnan(cv1))=0;
cv1(isinf(cv1))=0;

cv2 = so2 ./(po2 * delta_t);
cv2(isnan(cv2))=0;
cv2(isinf(cv2))=0;
warning on;
%pause;