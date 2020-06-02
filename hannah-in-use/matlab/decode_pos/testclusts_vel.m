function f = testclusts_linear(time, clusters, pos, bounds, varargin)

length(varargin)
pos4rank = pos;
vel4rank = velocity(pos);

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'rank'};


for k = 0:numclust


  if k>0
    ridname = clustname(k)
    newclusts = rmfield(clusters,char(ridname));
  vel = decodeshitVel(time, newclusts, vel4rank, 1, 1, 1);
  else
    ridname = 'none';
  vel = decodeshitVel(time, clusters, vel4rank, 1, 1, 1);
end

  if length(varargin)<1
  [ranks pval]= velrankresults(pos4rank, vel4rank, pos4rank, vel, 8, 8, 12, 0, 0, bounds);
  else
  [ranks pval]= velrankresults(pos4rank, vel4rank, cell2mat(varargin), vel, 8, 8, 12, 0, 0, bounds);
  end



  newdata = {ridname; pval};
  output = horzcat(output, newdata);


  numclust-k
end

f = output';
