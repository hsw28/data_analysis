function [cycle_centers, cycle_bouts, cycle_depth,opt] = find_theta_cycles(mua_rate, varargin)
% [cycle_centers, cycle_bouts] = find_theta_cycles(mua_rate)
% Identify trougs in firing rate as edges of theta cycles; middle points
% are found to represent the 'center time' of each cycle - this can be half
% way between the trougs, or at the mean MUA peak
% 'eeg_r' optional parameter helps identify cycles with low MUA activity
% the offest between MUA and eeg_r phases is determined and assumed to stay
% the same throughout the recording

p = inputParser();
p.addParamValue('cycle_depth_threshold',0.5);
p.addParamValue('eeg_r',[]);
p.addParamValue('filter',true);
p.addParamValue('filt_d_band',[]);
p.addParamValue('filt_d_low',[]);
p.parse(varargin{:});
opt = p.Results;

mua_ts = conttimestamp(mua_rate);
dt = mua_ts(2) - mua_ts(1);
spike_rate= double(permute(sum(mua_rate.data,2), [2,1]));

if(opt.filter)
if(isempty(opt.filt_d_band))
    disp('Running slow b/c no input parameter filt_d_band');
    h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', 4, 5, 10, 12, 50,1,50, mua_rate.samplerate);
    opt.filt_d_band = design(h,'equiripple');
    disp('Finished making filt_d_pass');
end
theta_rate = filtfilt(opt.filt_d_band.Numerator, 1, spike_rate);
if(isempty(opt.filt_d_low))
    disp('Running slow b/c no input parameter filt_d_low');
    h = fdesign.lowpass('fp,fst,ap,ast', 10, 12, 1, 50, mua_rate.samplerate);
    opt.filt_d_low = design(h, 'equiripple');
    disp('Finished making filt_d_low');
end
lowpass_rate = filtfilt(opt.filt_d_low.Numerator,1,spike_rate);
else
    theta_rate = spike_rate;
    lowpass_rate = spike_rate;
end

is_center = gh_is_local_max(theta_rate);
is_trough = gh_is_local_min(theta_rate);

% only count centers that are between toughs (ie. drop the centers at the
% extremes of the recording session)
first_center_ind = find( is_center, 1, 'first' );
first_trough_ind = find (is_trough, 1, 'first' );
last_center_ind = find( is_center, 1, 'last' );
last_trough_ind = find (is_trough, 1, 'last');
if(first_center_ind < first_trough_ind)
    is_center(first_center_ind) = false;
end
if(last_center_ind > last_trough_ind)
    is_center(last_center_ind) = false;
end

is_center = logical(is_center);
is_trough = logical(is_trough);

cycle_centers = mua_ts(is_center);
trough_times = mua_ts(is_trough);
cycle_bouts = [ trough_times(1:(end-1))' , trough_times(2:end)'];

% measure theta modulation depth
this_center_rate = lowpass_rate( is_center );
trough_rate = lowpass_rate( is_trough );
this_early_rate = trough_rate( 1 : (end-1) );
this_late_rate    = trough_rate(2 : end );
this_trough_rate = ( this_early_rate + this_late_rate )/2;
this_trough_rate = max(this_trough_rate, zeros(size(this_trough_rate)));
cycle_depth = (this_center_rate - this_trough_rate) ./ this_center_rate;