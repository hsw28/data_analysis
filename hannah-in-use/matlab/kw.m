function [P, ANOVATAB, STATS] = kw(data1, data2);

% performs a Kruskal-Wallis test on two groups of data. must be column format
%
% [P, ANOVATAB, STATS] = kw(data1, data2);

%combine data
combo = [data1; data2];

%define groups
groups = [ones(size(data1)); 2 * ones(size(data2))];

% do test
[P,ANOVATAB,STATS] = kruskalwallis(combo, groups)

