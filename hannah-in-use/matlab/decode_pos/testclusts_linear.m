function f = testclusts(time, pos, clusters, tdecode, dim)

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'mean'; 'median'; 'linear_mean'; 'linear_median'};

for k = 1:numclust
  ridname = clustname(k);
  newclusts = rmfield(clusters,char(ridname));
  [decoded allvec] = decodeshitPos_linear(time, pos, newclusts, tdecode, dim);
  %error
  error = decodederror(decoded, pos, tdecode);
  error_av = nanmean(error(1,:));
  error_med = nanmedian(error(1,:));

  error = decodederror_linear(decoded, pos, tdecode, allvec);
  error_lin_av = nanmean(error(1,:))
  error_lin_med = nanmedian(error(1,:))

  newdata = {ridname; error_av; error_med; error_lin_av; error_lin_med};
  output = horzcat(output, newdata);
  numclust-k
end

f = output';
