function [a, lags, b] = eventavg(trigger, time, data, varargin)
%EVENTAVG compute event triggered average
%
%  a=EVENTAVG(trigger,time,data) This will compute an event triggered
%  average. The first argument is a vector of event times, the second
%  argument is a vector of time values at which the data matrix is sampled.
%  The first dimension of the data matrix should have the same length as
%  the time vector (at least two time points are required). The data is
%  interpolated for 2 seconds at 1/fs steps around each trigger, where fs
%  is computed as mean(diff(time)). The size of the return value is nlags x
%  size(data,2) x ... x size(data, ndims(data)).
%
%  a=EVENTAVG(...,parm1,val1,...) Allows extra options to be set. Valid
%  options are:
%   lags - minimum and maximum lag (default=[-1 1])
%   fs - sampling frequency (default=computed from time vector)
%   interp - interpolation method (default='linear')
%   method - slow/fast (default='fast') The slow method has lower
%            memory overhead compared to the fast method, but does
%            only support nanmean and nansum functions.
%   function - string or function handle (default='nanmean'). The function
%              should accept two arguments: fcn(matrix,dim), where dim is
%              always 1.
%
%  [a,lags,b]=EVENTAVG(...) returns a columns vector of lags and a matrix b
%  that contains the interpolated data for each trigger. The size of b is
%  ntriggers x nlags x size(data,2) x ... x size(data,ndims(data)).
%  If method=='slow', output b is always empty.
%


%  Copyright 2007-2008 Fabian Kloosterman

%check arguments
if nargin<3
  help(mfilename)
  return
end

if ~isnumeric(trigger)
    error('eventavg:invalidArgument', 'Invalid triggers')
else
    trigger = trigger(:);
end

if ~isnumeric(time) || ~isvector(time) || isscalar(time)
    error('eventavg:invalidArgument', 'Invalid time vector')
else
    time = time(:);
end

if ~isnumeric(data) || size(data,1) ~= size(time,1)
    error('eventavg:invalidArgument', 'Invalid data matrix')
end

options = struct( 'lags', [-1 1], 'fs', [], 'interp', 'linear', 'method', 'fast', 'function', 'nanmean');
options = parseArgs(varargin, options);

if ~isnumeric(options.lags) || isempty(options.lags)
    error('eventavg:invalidArgument', 'Invalid lags')
end

if isempty(options.fs)
      options.fs = 1./mean(diff(time));
elseif ~isnumeric(options.fs) || ~isscalar(options.fs) || options.fs<=0
    error('eventavg:invalidArgument', 'Invalid sampling frequency')
end

if ~ischar(options.interp)
    error('eventavg:invalidArgument', 'Invalid interpolation method')
end

if ~ischar(options.method) || ~any(strcmp(options.method, {'fast','slow'}))
    error('eventavg:invalidArgument', 'Invalid method')
end

if ischar( options.function )
    options.function = str2func( options.function );
elseif ~isa( options.function, 'function_handle' )
    error('eventavg:invalidArgument', 'Invalid function')
end

if strcmp(options.method, 'slow')
    if ~ismember(func2str(options.function), {'nanmean', 'nansum'})
        error('eventavg:invalidArgument', 'The slow method only supports nanmean and nansum functions')
    else
        options.method = func2str( options.function );
    end
end

%permute dimensions of data to make time dimension first
%fwdperm = [options.dim setdiff(1:ndims(data),options.dim)];
%[invperm, invperm] = sort(fwdperm);

%data = permute(data,fwdperm);

lags = (options.lags(1):(1/options.fs):options.lags(end));

if strcmp(options.method,'fast')
    %compute the triggered average
    %this method is simple, but uses a lot of memory
    %advantage is that it is possible to return the
    %signals around all triggers
    
    b = interp1( time, data, bsxfun(@plus, trigger, lags ),...
        options.interp, NaN );

    %permute dimensions of output of interpolation, such that the final
    %size is ntriggers x nlags x [size(data)(2:end)]
    if isscalar(trigger) && ~isvector(data)
        %if only one lag, then interp1 'swallows' the first scalar
        %dimensions (except when data is a matrix), so restore it
        b = shiftdim( b, -1 );
    end
    if (isscalar(lags) && ~isscalar(trigger))
        %put the lags as the 2nd dimension, except when triggers is a
        %scalar and lags is not
        b = permute(b, [1 ndims(b)+1 2:ndims(b) ]);
    end

    %at this point the size of b should be: ntriggers x nlags x [size(data)(2:end)] 
    %now, compute mean or sum
    
    a = options.function( b, 1 );
    
    if size(a,1)~=1
        error('eventavg:invalidFunction', 'Function should return a scalar along first dimension')
    end
    
    a = shiftdim( a, 1);
    
else
    
    %this a slower method, but without the memory overhead
    %downside is that we do not keep the signal around each trigger
    %which means output argument b is always empty
    
    sz = size(data);
    a = zeros([numel(lags) sz(2:end)]);
    b = [];
    n = 0;
    
    for k=1:numel(trigger)
        
        tmp = interp1( time, data, trigger(k) + lags, options.interp, NaN);

        notnan = ~isnan(tmp);
        
        n = n + notnan;
        
        a(notnan) = a(notnan) + tmp(notnan);
        
    end

    if strcmp( options.function, 'nanmean' );
        a = a./n;
    end
    
    a(n==0)=NaN;
    
end
