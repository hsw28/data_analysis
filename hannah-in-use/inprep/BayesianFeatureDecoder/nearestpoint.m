function [idx, dist] = nearestpoint(x,y,m)
%NEARESTPOINT find the nearest value in y for x
%
%  idx=NEARESTPOINT(x,y) for each element in x returns the index of the
%  nearest value in y. Vector y should be sorted.
%
%  [idx,dist]=NEARESTPOINT(x,y) also returns the distance between the
%  value in x and the nearest value in y.
%
%  [...]=NEARESTPOINT(x,y,'pre') for every element in x finds the
%  nearest smaller element in y. If an element in x is smaller than any
%  element in y, then NaN is returned.
%
%  [...]=NEARESTPOINT(x,y,'post') for every element in x finds the
%  nearest larger element in y. If an element in x is larger than any
%  element in y, then NaN is returned.
%  

%  Copyright 2005-2008 Fabian Kloosterman

%assume y is sorted
if ~issorted(y)
    error('nearestpoint:notSorted', 'Y should be sorted!')
end

if nargin<3 || isempty(m)
  m = 'nearest';
end

%find nearest through interpolation
switch m
 case {'nearest'}
  idx = interp1(y, (1:numel(y))', x, 'nearest', 'extrap');       
 case {'pre', 'previous', 'before'}
  idx = interp1(y, (1:numel(y))', x, 'linear', 'extrap');
  if idx>numel(y)
    idx = numel(y);
  elseif idx<1
    idx = NaN;
  else
    idx = floor(idx);
  end
 case {'post', 'next', 'after'}
  idx = interp1(y, (1:numel(y))', x, 'linear', 'extrap');
  if idx<1
    idx = 1;
  elseif idx>numel(y)
    idx = NaN;
  else
    idx = ceil(idx);
  end
 otherwise
  error('neasrestpoint:invalidArguments', 'Invalid option')
end

valid = find( ~isnan(idx) );

%compute distance to nearest value
dist = NaN(size(x));
dist(valid) = abs( x(valid) - y(idx(valid)) );
