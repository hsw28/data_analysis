function [n_weighted,ind] = gh_whistc(x,w,edges,varargin)


% gh_whistc takes arguments x, w, edges [, means] [, means_count_zeros] [,ind_zeros_filtered_out]
% returns [n_weighted, ind]
% function behaves like histc, except that counted elements with property x
% may each be assigned weight w.  Bin counts are summed (default) or
% averaged (if 'means' property is true).  Zeros may be counted towards the
% mean (default) or not (if 'means_count_zeres' is set to false).
% ind_zeros_filtered_out assignes 0 to the ind of any x with weight 0

p = inputParser();
p.addParamValue('means',false,@islogical);
p.addParamValue('means_count_zeros',true,@islogical);
p.addParamValue('ind_zeros_filtered_out',false,@islogical);
p.parse(varargin{:});


% shape the vectors as I want.. 
[max_size,max_ind] = max(size(x));
if(max_ind == 1)
    
    disp(['gh_whistc says: old size(x) was ', num2str(size(x)),'.  SWITCHING INPUT DIMENSIONS']);
    x = x';
    w = w';
end

if(not(all(size(x) == size(w))))
    disp('Size of x:'); disp(size(x));
    disp('Size of w:'); disp(size(w));
    disp('x and w must be same size');
    warning('WARNING: X AND W ARE OF DIFFERENT SIZE!!!');
    smaller_num = min([size(x,2),size(w,2)]);
    w = w(:,1:smaller_num);
    x = x(:,1:smaller_num);
    %figure; subplot(1,2,1); hist(x); figure;
    %subplot(1,2,2); hist(w);
    disp('Second Size of x:'); disp(size(x));
end

% get the regular histc counts and indices
[n,ind] = histc(x,edges);

% make an array, n_bins high by numel(x) long
% this will eventually be used in a 'truth table' for whether each bin_m holds x_n
n_bins = numel(edges);
edges_big = [1:n_bins]' * ones(size(x));

% ind_big will also be used in truth table
ind_big = repmat(ind,n_bins,1);

% expand w to match truth table size
w = repmat(w,n_bins,1);

% keep_array is the truth table
keep_array = (ind_big == edges_big);

% weigh ones in the truth table by weights in w
weighted_array = keep_array .* w;

n_weighted = sum(weighted_array,2)';

if(p.Results.means)
    if(p.Results.means_count_zeros)
        n_unweighted = sum(keep_array,2)';
    else
        keep_array_dne_zero = (w ~= 0);
        keep_array_x_zeroed_when_w_zeroed = keep_array .* keep_array_dne_zero;
        n_unweighted = sum(keep_array_x_zeroed_when_w_zeroed,2)';
    end
    n_weighted = n_weighted ./ n_unweighted;
end

if(p.Results.ind_zeros_filtered_out)
    ind(w == 0) = 0;
end

% undo any vector transposing I did earlier.
if(max_ind ==1)
    n_weighted = n_weighted';
    ind = ind';
end

return