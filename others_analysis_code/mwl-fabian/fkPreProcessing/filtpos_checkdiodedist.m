function [data, stats] = filtpos_checkdiodedist(data, threshold)
%FILTPOS_CHECKDIODEDIST filter data for inter diode distances that are too large
%
%  data=FILTPOS_CHECKDIODEDIST(data) find all diode positions that have
%  an inter-diode distance lower than 25% quartile -
%  1.5*inter-quartile-range anf higher than 75% quartile +
%  1.5*inter-quartile-range and set those to NaN. Data is a nx4 matrix of
%  diode1 x,y and diode2 x,y coordinates.
%
%  data=FILTPOS_CHECKDIODEDIST(data,threshold) uses the specified
%  threshold that defines the range of valid diode positions, instead of
%  the default of 1.5.
%
%  [data,stats]=FILTPOS_CHECKDIODEDIST(...) returns a structure with
%  information about the operation.
%

%  Copyright 2005-2006 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(threshold)
    threshold = 1.5;
end

if size(data,2)~=4
    error('filtpos_checkdiodedist:invalidArguments', ...
          'Invalid position data matrix')
end

stats.arguments.threshold = threshold;

%calculate distance
distance = sqrt( sum ( ( data(:,1:2) - data(:,3:4) ).^2 , 2) );

valid = find( ~isnan(distance) );

%find quartiles and inter-quartile-distance
stats.quartiles = quantile( distance(valid), [0.25 0.5 0.75] );
stats.iqr = iqr( distance(valid));

%determine lower and upper bounds
lowbound = stats.quartiles(1) - threshold*stats.iqr;
highbound = stats.quartiles(3) + threshold*stats.iqr;

%set elements with invalid distance to NaN
idx = find( distance(valid) > (highbound) | distance(valid) < (lowbound) );
data(valid(idx), :) = NaN;

stats.ninvalid = numel(idx);