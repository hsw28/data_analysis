function varargout = apply2struct( fcn, argin, varargin )
%APPLY2STRUCT apply function to fields in structs
%
%  [out1,out2,...]=APPLY2STRUCT(fcn,argin,structA,structB,...) applies a
%  function field-wise to a set of structures, which all should have
%  the same fields. Argin should be a cell array with additional,
%  fixed arguments for the function. For each field in the structures,
%  the function is called as: fcn( structA(n), structB(n), ..., argin{:} ).
%
%  Example
%    X = struct( 'a', rand(10,1), 'b', rand(10,1) );
%    [Y, I] = apply2struct( @sort, {1, 'descend'}, X );
%
%  Example
%    X = struct( 'a', 1, 'b', [5 10] );
%    Y = struct( 'a', rand(10,1), 'b', [-3 6] );
%    Z = apply2struct( @plus, [], X, Y );
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
  error('apply2struct:invalidFunction', 'Not a valid function')
end

%make sure argin is a cell array
if isempty(argin)
  argin = {};
elseif ~iscell(argin)
  argin = {argin};
end

nIn = numel(varargin);
nOut = nargout;

%test if inputs are structs
if ~all( cellfun( 'isclass', varargin, 'struct' ) )
  error('apply2struct:invalidArguments', 'Arguments should be structs')
end

%test if structs are scalars
nd = cellfun('ndims', varargin);
ne = cellfun('prodofsize', varargin);
if ~all(nd==2) || ~all(ne==1)
  error('apply2struct:invalidArguments', ['Only scalar structs ' ...
                      'supported']);
end

if nargout(fcn)>=0 && nOut>nargout(fcn)
  error('apply2struct:invalidFcn', 'More outputs than supported by function');
end

%test if all structs have the same fields and convert to cell
fn = fieldnames( varargin{1} );
N = numel(fn);

tmp_in = cell( N, nIn );
tmp_in(:,1) = struct2cell(varargin{1});

for k=2:nIn
  if ~isequal( fn, fieldnames( varargin{k} ) )
    error('apply2struct:invalidArguments', ['Structs should ' ...
                        'have the same fields']);
  end
  tmp_in(:,k) = struct2cell(varargin{k});
end


if nOut==0

  for k=1:N
    
    fcn( tmp_in{k,:}, argin{:} );
   
  end
  
else
  
  tmp_out = cell( [N nOut] );

  for k=1:N
    
    [tmp_out{k,:}] = fcn( tmp_in{k,:}, argin{:} );
   
  end

  varargout = cell( 1, nOut );

  [varargout{:}] = uncat( 1, cell2struct( tmp_out, fn, 1 ) );
  
end
