function c = segcount( segs, x )
%SEGCOUNT cumulative count of segments
%
%  fcn=SEGCOUNT(segments) returns a handle to a function that accepts a
%  single argument and returns the cumulative count of segments at the
%  values in the argument. (i.e. the function counts the number of
%  segments which contain the value of the argument).
%
%  c=SEGCOUNT(segments,x) returns the count of segments at x.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check arguments
if nargin<1
  help(mfilename)
  return
end

%create function handle
c = @(x) subfcn( segs, x );

%return count if 2nd argument is provided
if nargin>1
  c = c(x);
end


function c = subfcn( segs, x )
%compute count of segments at values in x
%note that it is simple to get this count for a single value in x using
%'find', however the following method is faster when x is a vector

n = size(segs,1);
nx = numel(x);

q = sortrows([ [segs(:,1);x(:)] [zeros(n,1); ones(nx,1)]], [1 2] );
qi = find( q(:,2) );
cs = cumsum( q(:,2) );
segstart = qi - cs(qi);

q = sortrows([ [segs(:,2);x(:)] [zeros(n,1); ones(nx,1)]], [1 2] );
qi = find( q(:,2) );
cs = cumsum( q(:,2) );
segend = qi - cs(qi);

c = segstart - segend;
