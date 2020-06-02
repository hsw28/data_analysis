function f = testclusts_linear(time, pos, clusters, tdecode, dim)

pos4rank = pos;
vel4rank = velocity(pos);

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'mean'; 'median'; 'linear_mean'; 'linear_median'; 'rank'; 'num'};

%figure
for k = 0:numclust

  if k == 0
  ridname = 'none'
  [decoded bounds] = decodeshitPos_linear(time, pos, clusters, tdecode, dim);

  else

  ridname = clustname(k)

  newclusts = rmfield(clusters,char(ridname));

  %for troubleshooting
  %ridname = char(ridname);
  %clust.new = clusters.(ridname);
  %[decoded bounds] = decodeshitPos_linear(time, pos, clust, tdecode, dim);
  %

  [decoded bounds] = decodeshitPos_linear(time, pos, newclusts, tdecode, dim);

  end



  error = decodederror(decoded, pos, tdecode);
  error_av = nanmean(error(1,:));
  error_med = nanmedian(error(1,:));

  error = decodederror_linear(decoded, pos, tdecode, bounds);
  error_lin_av = nanmean(error(1,:));
  error_lin_med = nanmedian(error(1,:));

  [ranks pval]= velrankresults(pos4rank, vel4rank, decoded, vel4rank, 8, 8, 12, 0, 0, bounds);

  %ranks = 0;
  %pval = 0;

  numpoint = length(ranks)

  newdata = {ridname; error_av; error_med; error_lin_av; error_lin_med; pval; numpoint};
  output = horzcat(output, newdata);


  %subplot(numclust+1, 1, k+1)
  %scatter(decoded(1,:), decoded(2,:))

  numclust-k
end

f = output';
