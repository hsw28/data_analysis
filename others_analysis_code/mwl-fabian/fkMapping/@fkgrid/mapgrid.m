function m = mapgrid( G, coords, varargin )
%MAPGRID create a map
%
%  m=MAP(grid,coords) make a histogram of the specified n-dimensional
%  coordinates using the n-dimensional grid.
%
%  m=MAP(grid,coords,param1,value1,...) takes extra options:
%  Default - the default value for empty bins (default=NaN)
%  Function - the function to create the map (default = @length)
%
%  m=MAP(grid,coords,variable,...) uses the variable, which are values
%  measured at the specified coordinates, to create the map.
%
%  Example
%    grid = fkgrid( 1:0.01:1, 1:0.01:1 );
%    m = map( grid, rand(50,2), 'Function', @mean)
%

%  Copyright 2006-2008 Fabian Kloosterman

args = struct( 'Default', NaN, 'Function', @length );

[args,other] = parseArgs( varargin, args );

if isempty(other)
  variable = ones( size(coords,1), 1);
else
  variable = other{1};
end

bins = bin( G, coords );

valids = all(bins,2);

[b,i,j] = unique(bins(find(valids),:), 'rows'); %#ok

[rb, cb] = size(b);
b = mat2cell(b, rb, ones(cb,1));
szg = size(G);
if numel(szg)==1
  szg = [szg 1];
end

%do the mapping
m = zeros( szg ) + args.Default;

if size(coords,1)==0
  return
end

ind = sub2ind(szg, b{:});

variable = variable(find(valids));


for d=1:rb
    
    m(ind(d)) = args.Function( variable( find(j==d) ) );
    
end