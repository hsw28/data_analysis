function bins = centers2edges(cent)

dCent = diff(cent);
if ~all(dCent == mean(dCent) )
    error('Centers must be evenly spaced');
end
dCent = mean(dCent);
bins = cent - dCent/2;
bins(end+1) = bins(end)+dCent;