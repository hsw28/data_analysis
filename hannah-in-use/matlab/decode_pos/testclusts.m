function f = testclusts(time, pos, clusters, tdecode, dim)

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'median'; 'mean'};

for k = 1:numclust
  ridname = clustname(k);
  newclusts = rmfield(clusters,char(ridname));
  decoded = decodeshitPos(time, pos, newclusts, tdecode, dim);
  %error
  error = decodederror(decoded, pos, tdecode);

  newdata = {ridname; nanmedian(error(1,:));   nanmean(error(1,:))};
  output = horzcat(output, newdata);
  numclust-k
end

f = output';
