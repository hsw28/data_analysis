function varargout = zerocrossing(varargin)
%ZEROCROSSING find zero crossings in signal
%
%  zc=ZEROCROSSING(x) returns all (interpolated) indices with zero
%  crossings in x. Zero crossings are defined as any transition from -/0
%  to + or from +/0 to -. Note that this will include "zero
%  touches". Also, in case of a sequence of zeros, the last one will be
%  detected as the zero crossing.
%
%  [p2n,n2p]=ZEROCROSSING(x) returns + to - and - to + crossings only.
%
%  [p2n,n2p,zt]=ZEROCROSSING(x) returns zero touches as well.
%
%  [...]=ZEROCROSSING(t,x) returns the interpolated time value from vector
%  t, instead of indices.
%

%  Copyright 2005-2008 Fabian Kloosterman

% partially based on code written by
% John D'Errico (woodchips@rochester.rr.com)

if nargin<1
    help(mfilename)
    return
end

if nargin>1
    t = varargin{1};
    x = varargin{2};
else
    x = varargin{1};
    t = [];
end

if ~isvector(x) || ~isnumeric(x)
    error('zerocrossings:invalidArgument', 'Invalid data vector')
end

if (~isvector(t) || numel(t)~=numel(x) || ~isnumeric(t) ) && ~isempty(t)
    error('zerocrossings:invalidArgument', 'Input vectors should have the same length')
end

if isempty(x)
  varargout = cell(1,nargout);
  return
end

ind = 1:(numel(x)-1);

% list of intervals with a zero crossing
k = find(((x(ind)<=0) & (x(ind+1)>0)) | ((x(ind)>=0) & (x(ind+1)<0)));
           
% list of zero crossings
zc = [];

% find the (interpolated) indices
if ~isempty(k)
    s = (x(k+1)-x(k));
    zc = [zc, k - x(k)./s];
end

% patch for last element exactly zero
if x(end)==0
    zc(end+1) = numel(x);
end

% find all non-zero elements in x
zz = find( x~=0 );

% find the indices of the non-zero elements in x before and after zero
% crossings, first find the nearest ...
iz = interp1(zz, 1:numel(zz), zc, 'nearest');

% get rid of zero crossings due to all zeros at start or end of vector
valid = find( ~isnan(iz) );

% ... now find the other one
ii = ones( size( iz(valid) ) );
ii( zz( iz(valid) ) > zc(valid) ) = -1;

if ~isempty(t)
    ind = (1:numel(t))';
    zc = interp1( ind, t, zc, 'linear' );    
end

% find "zero-touches"
zt = zc( valid( sign( x( zz(iz(valid)) ) ) == sign( x( zz(iz(valid)+ii) ) ) ) );

% find - to + crossings
n2p = setdiff( zc( valid( x(zz(iz(valid))).*ii < x(zz(iz(valid)+ii)).*ii ) ), zt );

% find + to - crossings
p2n = setdiff( zc( valid( x(zz(iz(valid))).*ii > x(zz(iz(valid)+ii)).*ii ) ), zt );



% assign outputs
if nargout <=1 
    varargout{1} = zc;
elseif nargout >= 2
    varargout{1} = p2n;
    varargout{2} = n2p;
end

if nargout>2
    varargout{3} = zt;
end