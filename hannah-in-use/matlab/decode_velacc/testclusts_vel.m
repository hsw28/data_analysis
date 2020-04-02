function f = testclusts_vel(timevector, clusters, vel, tdecode, t, type)

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'median'; 'mean'};

for k = 0:numclust
  if k==0
      [values probs vbin median_is mean_is]  = decodeshitVel(timevector, clusters, vel, tdecode, t, type);
      ridname = 'NaN';
  else
  ridname = clustname(k);
  newclusts = rmfield(clusters,char(ridname));
  [values probs vbin median_is mean_is] = decodeshitVel(timevector, newclusts, vel, tdecode, t, type);
  end
  %error
  newdata = {ridname; median_is; mean_is}
  output = horzcat(output, newdata);
  numclust-k
end

f = output';
