function f = testclusts_linear(time, clusters, pos, bounds, varargin)

length(varargin)
pos4rank = pos;
vel4rank = velocity(pos);

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

if length(cell2mat(varargin))>1
  output = {'cluster name'; 'rank'; 'p with ranked pos'};
else
output = {'cluster name'; 'rank'};
end


for k = 0:numclust


  if k>0
    ridname = clustname(k)
    newclusts = rmfield(clusters,char(ridname));
  vel = decodeshitVel(time, newclusts, vel4rank, 1, 1, 1);
  else
    ridname = 'none';
  vel = decodeshitVel(time, clusters, vel4rank, 1, 1, 1);
end

[ranks pval]= velrankresults(pos4rank, vel4rank, pos4rank, vel, 8, 8, 12, 0, 0, bounds);


  if length(cell2mat(varargin))>1
    [ranks pvalvel]= velrankresults(pos4rank, vel4rank, cell2mat(varargin), vel, 8, 8, 12, 0, 0, bounds);
newdata = {ridname; pval; pvalvel};
output = horzcat(output, newdata);
  else
  newdata = {ridname; pval};
  output = horzcat(output, newdata);

  end





  numclust-k
end

f = output';
