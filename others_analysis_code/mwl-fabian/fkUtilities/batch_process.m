function varargout = batch_process( fcn, varargin)
%BATCH_PROCESS call function multiple times with different input arguments
%
%  varargout=BATCH_PROCESS(fcn,arg1,arg2,...) calls a function multiple
%  times with different input arguments and collects the results. Input
%  arguments are cell vectors or numeric vectors, which share the same
%  length or are scalars or strings. Character arrays are not supported.
%
%  varargout=BATCH_PROCESS(fcn,args) arguments can be specified as a
%  single cell matrix. The function will be called for every row in the
%  cell matrix.
%
%  Example
%    out = batch_process( @cat, 2, {'Peter', 'John'}, ' is a ', {'fool',
%    'good fellow'} );
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
end

nIn = numel(varargin);
nOut = nargout;

%default function is @numel
if isempty(fcn)
  fcn = @numel;
elseif ischar(fcn)
  fcn = str2func(fcn);
elseif ~isa(fcn, 'function_handle')
  error('batch_process:invalidFunction', 'Not a valid function')
end

if nIn == 1
  if ndims(varargin{1})~=2
    error('batch_process:invalidArguments', 'input is not a 2D cell array');
  end
  tmp_in = varargin{1};
  nIter = size( tmp_in, 1 );
else
  ic = cellfun( 'isclass', varargin, 'char');
  ne = cellfun( 'prodofsize', varargin );
  
  if any( ~ic )
    nIter = max(ne(~ic));
  else
    nIter = 1;
  end
  
  if any( ne~=1 & ne~=nIter & ~ic )
    error('batch_process:invalidArguments', ['Arguments should ' ...
                        'have the same length or should be scalar'])
  end
  
  tmp_in = cell( nIter, nIn );
  
  for k=1:nIn
    
    if iscell(varargin{k})
      tmp_in(:,k) = varargin{k}(:);
    elseif isscalar(varargin{k}) || ischar(varargin{k})
      [tmp_in{:,k}] = deal( varargin{k} );
    else
      tmp_in(:,k) = mat2cell( reshape(varargin{k}, nIter, 1), ones(nIter,1), 1 );
    end
    
  end
end
  

if nOut == 0
  
  for k=1:nIter
  
    fcn( tmp_in{k,:} );
  
  end

else
  
  tmp_out = cell( [ nIter nOut] );
  
  for k=1:nIter
  
    [tmp_out{k,:}] = fcn( tmp_in{k,:} );
  
  end

  varargout = cell( 1, nOut);
  [varargout{:}] = uncat( 2, tmp_out );  
  
end


