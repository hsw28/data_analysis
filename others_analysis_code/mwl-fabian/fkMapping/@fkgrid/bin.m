function b = bin( G, coords, d )
%BIN bin coordinates
%
%  b=BIN(grid,coords) bin the n-D coordinates using the n-D grid. The
%  function returns for each coordinate the bins each of the dimensions
%  is located in.
%
%  b=BIN(grid,coords,dim) returns the bin number of the 1-D coordinates
%  along dimension dim.
%
%  Example
%    grid = fkgrid('linear', 1:100, 'linear', 0:10);
%    b = bin( grid, [1 2; 4 8]);
%    b = bin( grid, [2; 8], 2);
%
%  See also FKGRID/MAP
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<3 || isempty(d)
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error( 'fkgrid:bin:invalidIndex', 'Invalid dimension' )
end

if nargin<2 || isempty(coords)
  b = [];
  return
elseif ~isnumeric(coords) || size(coords,2)~=numel(d)
  error('fkgrid:bin:invalidArguments', 'Invalid coordinates matrix')
end

if nargin<3 || isempty(d)
  d = 1:numel(G.grid);
end

b = zeros( size(coords) );

for k = 1:numel(d)
  
  switch G.grid(k).type
   case 'linear'
    if ~isvector(G.grid(d(k)).vector)
      nbins = size(G.grid(d(k)).vector,1);
      v = G.grid(d(k)).vector';
      [dummy, b(:,k)] = histc( coords(:,k), v(:) ); %#ok
      even = mod(b(:,k),2)==0;
      b(even , k) = 0;
      b(~even, k) = (b(~even, k)-1)/2+1;
      b( b(:,k)>nbins, k ) = 0;      
    else
      nbins = numel(G.grid(d(k)).vector)-1;
      [dummy, b(:,k)] = histc( coords(:,k), G.grid(d(k)).vector ); %#ok
      b( b(:,k)>nbins, k ) = 0;
    end
   case 'circular'
    nbins = numel(G.grid(d(k)).vector)-1;
    tmp = limit2pi( G.grid(d(k)).vector-G.grid(d(k)).vector(1) );
    if tmp(end)<=eps
      tmp(end)=2*pi;
    end
    [dummy, b(:,k)] = histc( limit2pi( coords(:,k)-G.grid(d(k)).vector(1) ...
                                       ), tmp); %#ok

    b( b(:,k)>nbins, k ) = 0;    
  end
  
end
  
  