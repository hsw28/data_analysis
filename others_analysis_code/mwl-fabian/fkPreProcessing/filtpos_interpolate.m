function [data, stats] = filtpos_interpolate(data, method)
%FILTPOS_INTERPOLATE interpolate diode data
%
%  data=FILTPOS_INTERPOLATE(data) linearly interpolates all gaps in diode
%  position data.
%
%  data=FILTPOS_INTERPOLATE(data,method) uses the specified method for
%  interpolation.
%
%  [data,stats]=FILTPOS_INTERPOLATE(...) returns a structure with
%  information about the operation.
%

%  Copyright 2005-2006 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(method)
    method = 'linear';
end

%create stats struct
stats.arguments.method = method;
stats.interpolation = struct('ninvalid', 0);

n = size(data,1);

%interpolation for each column...
for i=1:size(data,2)
    idx = find( ~isnan( data(:,i) ) );
    stats.interpolation(i).ninvalid = n-numel(idx);
    data(:,i) = interp1(idx, data(idx,i), 1:size(data,1), method);
end