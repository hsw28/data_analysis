function varargout = apply2cell( fcn, argin, varargin )
%APPLY2CELL apply function element-wise to cell arrays
%
%  [out1,out2,...]=APPLY2CELL(fcn,argin,cellA,cellB,...) applies a
%  function element-wise to a set of cell arrays, which all should have
%  the same dimensions. Argin should be a cell array with additional,
%  fixed arguments for the function. For each element in the cell arrays,
%  the function is called as: fcn( cellA(n), cellB(n), ..., argin{:} ).
%
%  Example
%    X = { rand(10,1), rand(5,15) };
%    [Y, I] = apply2cell( @sort, {1, 'descend'}, X );
%
%  Example
%    X = { 1, [5 10] };
%    Y = { rand(10,1), [-3 6] };
%    Z = apply2cell( @plus, [], X, Y );
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input/output arguments
if nargin<3
  help(mfilename)
  return
end

%default function is @numel
if isempty(fcn)
  fcn = @numel;
elseif ischar(fcn)
  fcn = str2func(fcn);
elseif ~isa(fcn, 'function_handle')
  error('apply2cell:invalidFunction', 'Not a valid function')
end

%make sure argin is a cell array
if isempty(argin)
  argin = {};
elseif ~iscell(argin)
  argin = {argin};
end

nIn = numel(varargin);
nOut = nargout;

%test if inputs are cells
if ~all( cellfun( 'isclass', varargin, 'cell' ) )
  error('apply2cell:invalidArguments', 'Arguments should be cells')
end

%test if inputs have same # number dimensions
nd = num2cell( cellfun('ndims', varargin) );
if nIn>1 && ~isequal( nd{:} )
  error('apply2cell:invalidArguments', ['Arguments should have same ' ...
                      'dimensions'])
end
nd = nd{1};

%test if inputs have same size
sz = size(varargin{1});
for k=2:nIn
  if ~all( sz==size(varargin{k}) )
    error('fkUtilities:apply2cell:invalidArguments', ['Arguments should have same ' ...
                      'size'])
  end
end


if nargout(fcn)>=0 && nOut>nargout(fcn)
  error('apply2cell:invalidFcn', 'More outputs than supported by function');
end

N = numel(varargin{1});
tmp_in = reshape( cat( nd+1, varargin{:} ), [N nIn] );

if nOut==0
  
  for k=1:N 
  
    fcn( tmp_in{k, :}, argin{:} );
  
  end
  
else

  tmp_out = cell( [ N nOut] );
  
  for k=1:N 
  
    [tmp_out{k,:}] = fcn( tmp_in{k, :}, argin{:} );
  
  end

  varargout = cell( 1, nOut);
  [varargout{:}] = uncat( nd+1, reshape( tmp_out, [sz nOut] ) ); 

end

