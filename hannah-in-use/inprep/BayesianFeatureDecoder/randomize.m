function [M,I] = randomize(M, varargin )
%RANDOMIZE randomize a matrix
%
%  m=RANDOMIZE(m) randomize the values in matrix m along the first
%  dimension.
%
%  m=RANDOMIZE(m,dim) randomize along the specified dimension(s). If a
%  vector of dimensions is given, the matrix is randomized along each
%  of these dimensions.
%
%  m=RANDOMIZE(m,dim,groupdim) dimensions listed in the vector groupdim
%  are randomized together along the specified dimension(s) dim.
%
%  m=RANDOMIZE(m,...,param1,val1,...) specifies optional parameters.
%   method - shake/cycle randomizes by cycling or shaking along a
%            given dimension. Only one dimension dim is allowed for the
%            cycle method.
%   adjust - none/mean/max adjust the mean/max of grouped dimensions.
%   seed - seed for randomization
%
%  [m,i]=RANDOMIZE(...) also returns the (linear) indexes of the
%  randomized matrix into the original matrix.
%
%  Examples
%    m = [1 5
%         3 2
%         6 4];
%    randomize(m)     %randomize along the row dimension, possible
%                     %output: [3 5
%                     %         6 4 
%                     %         1 2]
%    randomize(m,2)   %randomize along the column dimension, possible
%                     %output: [5 1
%                     %         2 3
%                     %         4 6]
%    randomize(m,1,2) %randomize along the row dimension, but keeping
%                     %values together in the column dimension, possible
%                     %output: [6 4
%                     %         1 5
%                     %         3 2]
%

%  Copyright 2007-2008 Fabian Kloosterman

options = struct( 'method', 'shake', 'adjust', 'none', 'seed', []);
[options,other]=parseArgs(varargin,options);

if nargin<1
  help(mfilename)
  return
end

dim = 1;
groupdim = [];

if ~isempty(other)
  nargs = numel(other);
  if nargs>0 && ~isempty(other{1})
    dim = other{1};
  end
  if nargs>1
    groupdim = other{2};
  end
end

if strcmp( options.method, 'cycle' ) && numel(dim)>1
  error('randomize:invalidArgument', ['Cycle method only supports one ' ...
                      'randomization dimension'])
end

oldseed = [];
if ~isempty(options.seed)
  oldseed = rand('seed'); %#ok
  rand('seed',options.seed); %#ok
end

try

N = numel(M);
nd = ndims(M);

otherdim = setdiff( 1:nd, [dim groupdim] );

if ~all(ismember( dim, 1:nd )) || ~all(ismember( groupdim, 1:nd )) || ...
      ~isempty( intersect( dim, groupdim ) )
  error( 'randomize:invalidArgument', 'Invalid dim or groupdim arguments')
end

sz = size( M );

I = reshape( 1:N, sz );

dx = prod(sz(dim));
dy = prod(sz(otherdim));
dz = prod(sz(groupdim));

I = reshape( permute( I, [dim otherdim groupdim] ), [dx dy dz] );

if numel(groupdim)>=1
  switch options.adjust
   case 'mean'
    adjust_factor = nanmean( M(I),3 );
   case 'max'
    adjust_factor = nanmax( M(I),[],3 );
  end
end

[row_i, col_i, plane_i] = ndgrid( 1:dx, 1:dy, 1:dz );

switch options.method
 case 'cycle'
  row_i = randcycle( row_i(:,:,1) );
 otherwise
  [row_i,row_i] = sort(rand([dx dy]),1);
end

row_i = repmat( row_i, [1 1 dz] );

I = I( sub2ind( [dx dy dz], row_i, col_i, plane_i ) );

if numel(groupdim)>=1
  switch options.adjust
   case 'mean'
    adjust_factor = adjust_factor./nanmean( M(I),3 );
    M(I) = bsxfun(@times, M(I), adjust_factor );
   case 'max'
    adjust_factor = adjust_factor./nanmax( M(I),[],3 );
    M(I) = bsxfun(@times, M(I), adjust_factor );    
  end
end

I = ipermute( reshape( I, sz([dim otherdim groupdim]) ), [dim otherdim groupdim] );

M = M(I);

if ~isempty(oldseed)
  rand('seed', oldseed); %#ok
end

catch ME

  if ~isempty(oldseed)
    rand('seed', oldseed); %#ok
  end
  
  rethrow(ME);
  
end
