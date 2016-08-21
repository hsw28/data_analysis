function c = eventcount( events, x )
%EVENTCOUNT cumulative count of events
%
%  fcn=EVENTCOUNT(events) returns a handle to a function that accepts a
%  single arguments and returns the cumulative count of events up to the
%  value of argument.
%
%  c=EVENTCOUNT(events,x) returns the cumulative count of events up to x.
%


%check arguments
if nargin<1
  help(mfilename)
  return
end

%make column vector
events = events(:);

%create function handle
c = @(x) subfcn( events, x );
  
%return count if 2nd argument is provided
if nargin>1
  c = c(x);
end


function c = subfcn( events, x)
%compute cumulative count of events at values in x
%note that it is simple to get this count for a single value in x using
%'find', however the following method is faster when x is a vector

n = numel(events);
nx = numel(x);

q = sortrows([ [events;x(:)] [zeros(n,1); ones(nx,1)]], [1 2] );
qi = find( q(:,2) );
cs = cumsum( q(:,2) );
c = qi - cs(qi);
