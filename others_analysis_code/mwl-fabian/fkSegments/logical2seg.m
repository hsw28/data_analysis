function seg = logical2seg( t, l)
%LOGICAL2SEG create segments from a logical array
%
%  seg=LOGICAL2SEG(x,v) given a vector of indices or a logical index
%  vector v, this function will return segments in x defined by those
%  indices.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if nargin<2
  l = t;
  t = 1:numel(l);
end

if numel(l) == numel(t)
  %l is an logical vector
  l = find( l );
else
  %l is an index vector
end

l = l(:);

if isempty(l)
    seg = zeros(0,2);
    return
end;

segstart = l([1 ; 1+find( diff(l)>1 )]);
segend = l([find( diff(l)>1 ) ; numel(l)]);

%b = burstdetect( l, 'MinISI', 1, 'MaxISI', 1 );

%segstart = t( l(b==1) );
%segend = t( l(b==3) );


seg = t([ segstart(:) segend(:)]);
