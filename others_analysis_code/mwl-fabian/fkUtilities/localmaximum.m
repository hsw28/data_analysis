function i = localmaximum(varargin)
%LOCALMAXIMUM find local maxima
%
%  peak_i=LOCALMAXIMUM(x) returns indices of local maxima in the vector x.
%
%  peak_i=LOCALMAXIMUM(x,'method', 'gradient') uses a method that detects
%  zerocrossings in the gradient of x and returns the (interpolated)
%  indices of the local maxima.
%
%  peak_t=LOCALMAXIMUM(t,x,...) returns (interpolated) time values from
%  vector t instead of indices.
%

%  Copyright 2005-2009 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

options = struct('method', 'discrete');
[options, others] = parseArgs(varargin,options);

if isempty(others) || numel(others)>2
    error('localmaximum:invalidArgument', 'Need at least one and at most two vectors')
elseif isscalar(others)
    x = others{1};
    t = [];
else
    t = others{1};
    x = others{2};
end

if ~isvector(x) || ~isnumeric(x)
    error('localmaximum:invalidArgument', 'Invalid data vector')
end

if (~isvector(t) || numel(t)~=numel(x) || ~isnumeric(t) ) && ~isempty(t)
    error('localmaximum:invalidArgument', 'Input vectors should have the same length')
end

if ~ismember(options.method, {'discrete', 'gradient'})
    error('localmaximum:invalidArgument', 'Invalid value for method option')
end

switch options.method
    
    case 'gradient'
        
        [i, trough_idx] = zerocrossing( gradient( x ) ); %#ok

    otherwise
        
        %determine size of input array
        n = numel(x);

        d = 1+double(size(x,2)>1);
        
        %special case
        if n==1
            i = 1;
        else
            %find indices of local maxima
            i = find( diff( sign( diff(cat(d,0,x,0)) ) ) < 0 );
        end
    
end

if ~isempty(t)
    
    i = interp1( 1:numel(x), t, i, 'linear' );
    
end