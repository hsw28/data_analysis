function col_ind = gh_dcbn(clust,name)
col_ind = find(strcmp(name,clust.featurenames));
if(numel(col_ind) <1)
    warning('Call to gh_dcbn resulted in no matching featurenames.');
elseif(numel(col_ind) > 1)
    warning('Call to gh_dcbn resulted in multiple matching featurenames.');
    disp(col_ind);
    col_ind = col_ind(1);
end
return