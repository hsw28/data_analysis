function D=isolation_distance(D2,clusters)
%ISOLATION_DISTANCE compute isolation distance measure
%
%  d=ISOLATION_DISTANCE(distances,idx) where distances is a vector of
%  mahalanobis distances between feature vectors and the centroid of a
%  subset (i.e. cluster) of feature vectors (given by the indices idx).
%  Returns the isolation distance between the cluster and the remaining
%  spikes. if idx is a cell array of indices for c different clusters,
%  then distances should be a n-by-c matrix.
%

%check arguments
if isnumeric(clusters)
  clusters=clusters{1};
  D2=D2(:);
elseif ~iscell(clusters) || numel(clusters)~=size(D2,2)
  error('isolation_distance:invalidArgument', 'Invalid index argument')
end

%init
nc = numel(clusters);
nr = size(D2,1);
D = NaN(1,nc);

%loop through all clusters
for k=1:nc
  
  n = numel(clusters{k}); %number of spikes in cluster
   
  %continue if cluster has no spikes or if there are less spikes outside
  %the cluster than inside
  if n==0 || (nr-n)<n
    continue
  end
  
  %find indices NOT belonging to cluster
  idx = setdiff( 1:size(D2,1),clusters{k});
  %sort distances
  sortD2 = sort( D2(idx,k) );
  
  %find isolation distance
  D(k)=sortD2(n);
  
end
  