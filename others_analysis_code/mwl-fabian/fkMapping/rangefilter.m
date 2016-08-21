function f=rangefilter(range)
%RANGEFILTER create a filter function
%
%  f=RANGEFILTER(range) returns a function that will filter its inputs
%  for values that are within the range specified.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || isempty(range)
  range = [-Inf Inf];
end

f = @(x,varargin) internalfilter(x,range,varargin{:});


function [x,b]=internalfilter(x,default_range,varargin)

if nargin>3
  b = inrange(x,varargin{:});
else
  b = inrange(x,default_range);
end

x = x(b);
