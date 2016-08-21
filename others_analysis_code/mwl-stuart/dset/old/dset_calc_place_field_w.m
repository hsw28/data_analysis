function spikes = dset_calc_place_field_w(spike, pos, varargin)
% DSET_CALC_PLACE_FIELD_W - calculates the placefields for a W maze
%
%

stdArgs = dset_get_standard_args();

args.time_win = [-Inf Inf];
args.position_bin_width = stdArgs.placefields.positionBinWidth;
args.position_kernel_size = stdArgs.placefields.positionBinWidth;
args.vel_thold = stdArgs.placefields.velocityThreshold;
args = parseArgsLite(varargin,args);


posInd = pos.ts>=args.time_win(1) & pos.ts<=args.time_win(2);

ts = pos.ts(posInd);
lp = pos.lp(posInd);
lv = pos.lv(posInd);
spike_times = spike.st;

spikeInd = spike_times>=args.time_win(1) & spike_times<=args.time_win(2);
spike_times = spike_times(spikeInd);

% Interpolate the spike positions in each of the W maze sub trajectories
warning off;
spike_pos_c2l = interp1(pos.paths.c2l, pos.lp, spike_times, 'nearest');
spike_pos_c2r = interp1(pos.paths.c2r, pos.lp, spike_times, 'nearest');
spike_pos_l2r = interp1(pos.paths.l2r, pos.lp, spike_times, 'nearest');
spike_vel = interp1(pos.ts, pos.linvel, spike_times, 'nearest');
warning on;


range_c2l = min(pos.paths.c2l):args.position_bin_width:max(pos.paths.c2l);
range_c2r = min(pos.paths.c2r):args.position_bin_width:max(pos.paths.c2r);
range_l2r = min(pos.paths.l2r):args.position_bin_width:max(pos.paths.l2r);

%plot(spike_vel)

%pause;
%[size(spike_pos) size(spike_vel)]
spike_pos_dir1 = spike_pos(logical(spike_vel> args.vel_thold));
spike_pos_dir2 = spike_pos(logical(spike_vel< args.vel_thold * -1));

dir1_ind = (pos.linvel > args.vel_thold);
dir2_ind = (pos.linvel < args.vel_thold * -1);
%[sum(pos_dir1) sum(pos_dir2)]

posOccupancy_c2l_d1 = histc(pos.paths.c2l(dir1_ind), min(pos.paths.c2l) : args.position_bin_width : max(pos.paths.c2l)); 
posOccupancy_c2l_d2 = histc(pos.paths.c2l(dir2_ind), min(pos.paths.c2l) : args.position_bin_width : max(pos.paths.c2l)); 

posOccupancy_c2r_d1 = histc(pos.paths.c2r(dir1_ind), min(pos.paths.c2r) : args.position_bin_width : max(pos.paths.c2r)); 
posOccupancy_c2r_d2 = histc(pos.paths.c2r(dir2_ind), min(pos.paths.c2r) : args.position_bin_width : max(pos.paths.c2r));

posOccupancy_l2r_d1 = histc(pos.paths.l2r(dir1_ind), min(pos.paths.l2r) : args.position_bin_width : max(pos.paths.l2r)); 
posOccupancy_l2r_d2 = histc(pos.paths.l2r(dir2_ind), min(pos.paths.l2r) : args.position_bin_width : max(pos.paths.l2r)); 



po1 = histc(pos_dir1, range);
po1 = smoothn(po1, s_width, bin_width);
po2 = histc(pos_dir2, range);
po2 = smoothn(po2, s_width, bin_width);

so1 = histc(spike_pos_dir1, range);
so2 = histc(spike_pos_dir2, range);

if isempty(so1)
    so1 = zeros(1,32);
end
if isempty(so2)
    so2 = zeros(1,32);
end

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


end