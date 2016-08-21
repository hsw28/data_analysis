function v = topologicalsort( m )
%TOPOLOGICALSORT topological sort of connection matrix
%
%  v=TOPOLOGICALSORT(m) where m is a square matrix with each
%  element m(x,y) indicating if an edge is present from vertex x to
%  vertex y. The funciton returns the sorted connectivity matrix v.
%

%  Copyright 2009 Fabian Kloosterman

%check arguments
if nargin<1
    help(mfilename)
    return
end

if ~isnumeric(m) || ndims(m)~=2 || size(m,1)~=size(m,2)
    error('topologicalsort:invalidArgument', 'Need square matrix');
end

%convert to zeros/ones
m(m~=0)=1;

n = size(m,1);

idx = 1:n;

v = zeros(n,1);

for k=1:n
    
    nedge_in = sum( m(idx,idx) );
    vertex = find( nedge_in==0, 1, 'first' );
    
    if isempty(vertex)
        error('topologicalsort:cyclicGraph', 'This is a cyclic graph');
    end
    
    v(k) = idx(vertex);
    
    idx(vertex) = [];
    
end

v = m(v,v);