function count = sortedhist( X, bins ) %#ok
%SORTEDHIST histogram of sorted variable X
%
%  count=SORTEDHIST(x,bins) returns the number of elements in x that fall
%  in each bin. x should be a sorted vector. Bins are specified as nx2
%  matrix, each row contains the lower and upper bin edges. Bins should
%  be sorted according to their lower edges, but they are allowed to
%  overlap. For each bin the lower edge is inclusive, but not the upper
%  edge.
%
%  Example
%    H = sortedhist( 1:100, [1 10; 25 80; 50 90] );
%

%  Copyright 2005-2008 Fabian Kloosterman
