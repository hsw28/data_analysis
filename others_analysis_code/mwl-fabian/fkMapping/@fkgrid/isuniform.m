function b = isuniform( G, d )
%ISUNIFORM test whether grid is uniform
%
%  b=ISUNIFORM(grid) returns 1 for each grid dimension that is uniform
%  (i.e. uniform spacing and size of bins) or 0 for those that are
%  not. This method is not implemented for circular grids.
%
%  b=ISUNIFORM(grid,dim) performs test only on dimension dim
%
%  Example
%    grid = fkgrid('linear', [0:100], 'linear', [0 10 30 70 100]);
%    b=isuniform(grid);
%
%  See also FKGRID/ISCATEGORICAL
%

%  Copyright 2006-2008 Fabian Kloosterman


if nargin<2 || isempty(d)
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error('fkgrid:isuniform:invalidIndex', 'Invalid dimension')
end

b = ones( 1, numel(d) );

for k=1:numel(d)
  switch G.grid(d(k)).type
   case 'linear'
    ctrs = diff(diff(centers(G,d(k))));
    bsz = binsizes(G,d(k));
    bsz = bsz - mean(bsz);
    if (~isempty(ctrs) && (any(isnan(ctrs)) || any(ctrs>1e-10)))...
          || (~isempty(bsz) && (any(isnan(bsz)) || any(bsz>1e-10)))
      b(k) = 0;
    end
   case 'circular'
    error('fkgrid:isuniform:notImplemented', 'Not implemented')
  end
  
end
