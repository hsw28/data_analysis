function data = filtpos_checkspeed(data, threshold)
%FILTPOS_CHECKSPEED filter data for too high speed or acceleration
%
%  data=FILTPOS_CHECKSPEED(data) set all diode positions where the 1st or
%  2nd order gradient is larger than mean + 2*standard deviation to
%  NaN. Data is a nx4 matrix of diode1 x,y and diode2 x,y coordinates.
%
%  data=FILTPOS_CHECKSPEED(data,threshold) uses the specified threshold
%  to find the invalid diode positions, instead of the default of 2.
%

%  Copyright 2005-2006 Fabian Kloosterman

%THIS FUNCTION IS NOT USED
%OBSOLETE?

if nargin<2 || isempty(threshold)
    threshold = 2;
end

if size(data,2)~=4 && size(data,2)~=2
    error('filtpos_checkspeed:invalidArgument', 'Invalid position matrix')
end

ndiodes = size(data,2) / 2;

[fx, fy] = gradient( data ); %#ok
[fx, fy2] = gradient( fy ); %#ok

%process the two diode separately
for i = 1:ndiodes
    col_idx = [1 2] + 2*(i-1);
    speed_diode = sqrt( sum(fy(:,col_idx).^2, 2) );
    accel_diode = sqrt( sum(fy2(:,col_idx).^2, 2) );
    valid = find( ~isnan(speed_diode) & ~isnan(accel_diode) );
    mean_speed = mean(speed_diode(valid));
    std_speed = std(speed_diode(valid));
    mean_accel = mean(accel_diode(valid));
    std_accel = std(accel_diode(valid));

    idx =  speed_diode(valid) > (mean_speed + threshold * std_speed) | accel_diode(valid) > (mean_accel + threshold * std_accel);

    data(valid(idx), col_idx) = NaN;
end

