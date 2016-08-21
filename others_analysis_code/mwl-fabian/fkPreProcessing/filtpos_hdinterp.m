function [data, stats] = filtpos_hdinterp(data, method)
%FILTPOS_HDINTERP diode position interpolation using head direction and diode distance
%
%  data=FILTPOS_HDINTERP(data) fills in missing diode positions by
%  linearly interpolating head direction and diode distance.
%
%  data=FILTPOS_HDINTERP(data,method) using the specified interpoaltion
%  method.
%
%  [data,stats]=FILTPOS_HDINTERP(...) returns a structure with
%  information about the operation.
%

%  Copyright 2005-2006 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(method)
    method = 'linear';
end

if size(data,2)~=4
    error('filtpos_hdinterp:invalidArguments', 'Invalid diode position matrix')
end

stats.arguments.method = method;

%compute head direction and inter diode distance
hd = atan2( data(:,4)-data(:,2), data(:,3)-data(:,1) );
distance = sqrt( sum ( ( data(:,1:2) - data(:,3:4) ).^2 , 2) );

%find valid elements
idx = find( ~isnan(hd) );

%interpolate head direction
hd = unwrap(hd);
hd = interp1(idx, hd(idx), 1:length(hd), method)';

%interpolate inter diode distance
distance = interp1(idx, distance(idx), 1:length(distance), 'linear')';

%find all elements where diode 1 is invalid, but not diode 2 and vice versa
invalid_idx = [ (isnan( data(:,1) ) | isnan( data(:,2) )) (isnan( data(:,3) ) | isnan( data(:,4) ))] ;
invalid_idx(:,1) = invalid_idx(:,1) & ~invalid_idx(:,2);
invalid_idx(:,2) = invalid_idx(:,2) & ~invalid_idx(:,1);

stats.diode0.ninvalid = numel(find(invalid_idx(:,1)));
stats.diode1.ninvalid = numel(find(invalid_idx(:,2)));

%for both diodes...
for i = 0:1

  col_idx = [1 2]+2*i; % x,y column indexes for this diode
  alt_col_idx = [1 2]+2*(~i); %x,y column indexes for other diode

  %fill in those elements where we don't know the position of this diode,
  %but we do know the position of the other diode
  data(invalid_idx(:,1+i), col_idx) = data(invalid_idx(:,i+1), alt_col_idx) - (-2*i+1).*[cos(hd(invalid_idx(:,i+1))).*distance(invalid_idx(:,i+1)) sin(hd(invalid_idx(:,i+1))).*distance(invalid_idx(:,i+1))];

end