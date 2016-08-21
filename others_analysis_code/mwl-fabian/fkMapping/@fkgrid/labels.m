function val = labels(G,d, bins)
%LABELS get bin edges labels
%
%  l=LABELS(grid) return a cell array of cell array strings containing
%  text representations of the bin edges for each dimension
%
%  l=LABELS(grid,dim) return labels only for specified dimension
%
%  l=LABELS(grid,dim,bins) return labels only for specified bins
%
%  Example
%    grid = fkgrid(1:100);
%    lbls = labels(grid);
%
%  See also FKGRID/NAMES, FKGRID/EDGES
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d) 
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error( 'fkgrid:labels:invalidIndex', 'Invalid dimension' )
end

if nargin<3 || isempty(bins)
  bins = repmat( {[]}, 1, numel(d) );
elseif ~iscell( bins )
  bins = { bins };
end

if numel(bins)==1
  bins = repmat( bins, 1, numel(d) );
elseif numel(bins)~=numel(d)
  error('fkgrid:labels:invalidArguments', 'Invalid number of bin vectors specified');
end
  
sz = size( G );

for k=1:numel(d)
  if isempty(bins{k})
    %bins{k} = [1:(numel(G.grid(d(k)).vector)-1)]; %#ok
    bins{k} = 1:sz(d(k));
  elseif ~isnumeric(bins{k}) || any( bins{k}<1 | bins{k}>sz(d(k)))
    error('fkgrid:labels:invalidBins', 'Invalid bin vector' );
  end
  bins{k} = bins{k}(:);
end
  
val = {};

for k=1:numel(d)
  n = numel(bins{k});
  if strcmp(G.grid(d(k)).type, 'linear') && ~ ...
        isvector(G.grid(d(k)).vector)
    val{k} = cellstr( horzcat( num2str( G.grid(d(k)).vector(bins{k},1) ), ...
                               repmat(' : ', n, 1), ...
                               num2str( G.grid(d(k)).vector(bins{k},2) ) ...
                               ) );
  else
    val{k} = cellstr(horzcat( num2str( G.grid(d(k)).vector(bins{k}) ), repmat( ' : ', n, 1), num2str(G.grid(d(k)).vector(bins{k}+1)) ));
  end
end

if numel(d)==1
  val = val{1};
end