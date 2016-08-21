function f=circrangefilter(range)
%CIRCRANGEFILTER create a circular filter function
%
%  f=CIRCRANGEFILTER(range) returns a function that will filter its
%  inputs for values that are within the range specified.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || isempty(range)
  range = [0 2*pi];
end

f = @(x,varargin) internalfilter(x,range,varargin{:});


function [x,b]=internalfilter(x,default_range,varargin)

if nargin>2
  b = circ_inrange(x,varargin{:});
else
  b = circ_inrange(x,default_range);
end

x = x(b);
