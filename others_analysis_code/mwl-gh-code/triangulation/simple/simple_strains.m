function [strains] = simple_strains(dist_mat, signals_mat)

strains = abs(signals_mat - dist_mat);