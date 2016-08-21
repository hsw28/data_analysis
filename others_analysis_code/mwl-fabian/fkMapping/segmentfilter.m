function f=segmentfilter(segments)
%SEGMENTFILTER create a segment filter function
%
%  f=SEGMENTFILTER(segments) returns a function that will filter its inputs
%  for values that are within the segments specified.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1 || isempty(segments)
  segments = [-Inf Inf];
end

f = @(x,varargin) internalfilter(x,segments,varargin{:});


function [x,b]=internalfilter(x,default_segments,varargin)

if nargin>3
  b = inseg(varargin{1},x,varargin{2:end});
else
  b = inseg(default_segments,x);
end

x = x(b);
