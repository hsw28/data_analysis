function f = testclusts(time, pos, clusters, tdecode, dim)

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'median'; 'mean'};
figure

for k = 0:numclust
  if k == 0
      decoded = decodeshitPos(time, pos, clusters, tdecode, dim);
      ridname = 'NaN'
  else
  ridname = clustname(k);
  newclusts = rmfield(clusters,char(ridname));
  decoded = decodeshitPos(time, pos, newclusts, tdecode, dim);
  end
  %error

  error = decodederror(decoded, pos, tdecode);
hold on
  subplot(numclust+1,1,k+1)
  scatter(decoded(1,:), decoded(2,:))

  newdata = {ridname; nanmedian(error(1,:));   nanmean(error(1,:))};
  output = horzcat(output, newdata);
  numclust-k
end

f = output';
