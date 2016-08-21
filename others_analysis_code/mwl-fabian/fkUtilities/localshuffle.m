function v = localshuffle( v, w )
%LOCALSHUFFLE local shuffle vector
%
%  x=LOCALSHUFFLE(x,w) locally shuffle the elements of vector x. The
%  functions adds a random number between -w and w to the indices of the
%  elements of vector x and then resorts.
%

%  Copyright 2006-2008 Fabian Kloosterman

n = numel(v);

i = 1:n;

i = i + unifrnd( -w, w, 1, n );

[i, idx] = sort(i); %#ok

v = v(idx);
