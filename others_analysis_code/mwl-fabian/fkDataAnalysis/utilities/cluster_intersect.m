function varargout = cluster_intersect( varargin )
%CLUSTER_INTERSECT find clusters shared between epochs
%
%  idx=CLUSTER_INTERSECT(clusters1,clusters2,...) this function
%  finds the indices of the clusters in the provided clusters
%  structs which are present in all structs by comparing tetrode
%  and cluster id.
%

%  Copyright 2006-2008 Fabian Kloosterman


n = numel(varargin);

if n==0
  help(mfilename)
  return
elseif n==1
  varargout{1} = (1:numel(varargin{1}))';
  return
end

q = [[varargin{1}.tetrode]' [varargin{1}.cluster_id]'];

for cl=2:n
  
  q = intersect( q, [[varargin{cl}.tetrode]' [varargin{cl}.cluster_id]'], ...
                 'rows');
  
end

for cl=1:n
  
  [dummy, varargout{cl}] = ismember( q, [[varargin{cl}.tetrode]' ...
                      [varargin{cl}.cluster_id]'], 'rows'); %#ok
  
end