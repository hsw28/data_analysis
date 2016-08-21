function D2 = clustermahal( features, clusters)
%CLUSTERMAHAL mahalanobis distance between feature vectors and clusters
%
%  d2=CLUSTERMAHAL(features) computes the mahalanobis distance between
%  the feature vectors and the centroid of all features. Each row of the
%  features matrix is a feature vector.
%
%  d2=CLUSTERMAHAL(features,cluster) computes the mahalanobis distance
%  between the feature vectors and the centroid of the subset of features
%  identified by the cluster index vector. Cluster can also be a cell
%  array of index vectors, in that case the return value is a matrix
%  of distances.
%


if nargin<1
  help(mfilename)
  return
end

if ~isnumeric(features) || ndims(features)~=2 || any(size(features)==0)
  error('clustermahal:invalidArguments', 'Invalid features matrix')
end

if nargin==1
  clusters = {1:size(features,1)};
elseif ~iscell(clusters)
  if ~isnumeric(clusters) || ~isvector(clusters)
    error('clustermahal:invalidArguments', 'Invalid index vector')
  end
  clusters = {clusters};  
end

for k=1:numel(clusters)
  if isempty(clusters{k})
    D2(1:size(features,1),k)= NaN;
  else
    D2(:,k) = mahal( features, features(clusters{k},:) ); %#ok
  end
end

