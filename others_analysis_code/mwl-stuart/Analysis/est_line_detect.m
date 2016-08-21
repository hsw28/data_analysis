function [slope, intercept, score, projection] = est_line_detect( x, y, est, varargin )
%EST_LINE_DETECT detect line in time series of 1D PDFs
%
%  [slope,intercept,score,projection]=EST_LINE_DETECT(x,y,estimate)
%
%  [...]=EST_LINE_DETECT(...,parm1,val1,...)
%   method - (default=sum)
%   interp - interpolation method (default=nearest)
%   padmethod - padding method (default=median)
%   dtheta - theta sampling interval (defaul=0.01*pi)
%   drho - rho sampling interval (default=[])
%   kernel - smoothing kernel (default=box)
%   kernelwidth - size of smoothing kernel (default=[0 0])
%

%  Copyright 2009 Fabian Kloosterman

radon_options = struct( 'method', 'sum', ... %radon transform method: 'sum','product','logsum'
                        'interp', 'nearest', ... %interpolation: 'linear','nearest'
                        'padmethod', 'median', ...  %method of padding 'mean' of columns or 'random' draw from columns
                        'dtheta', 0.01*pi, ... %theta interval
                        'drho', [] ); %rho sampling interval

radon_options_fixed = struct( 'valid', 0, 'rho_x', 0, 'pad', 1, 'dx', 1, 'dy', 1, 'constraint', 'row' );

smooth_options = struct( 'kernel', 'box', 'kernelwidth', [0 0] );

smooth_options_fixed = struct( 'correct', 0, 'normalize', 0, 'nanexcl', 1 );


[radon_options, other, remainder] = parseArgs( varargin, radon_options );
smooth_options = parseArgs( remainder, smooth_options );

radon_options = cat(2, struct2param( radon_options ), struct2param( radon_options_fixed ) );

if nargin<3
    help(mfilename)
    return
end

if ~isnumeric(est) || ndims(est)~=2
    error('est_line_detect:invalidArgument', 'Invalid estimate')
end

if isempty(x)
    x = 1:size(est,2);
elseif ~isnumeric(x) || ~isvector(x) || numel(x)~=size(est,2) || ~ismonotonic(x,1,'i')
    error('est_line_detect:invalidArgument', 'Invalid time vector')
end

if isempty(y)
    y = 1:size(est,1);
elseif ~isnumeric(y) || ~isvector(y) || numel(y)~=size(est,1) || ~ismonotonic(y,1,'i')
    error('est_line_detect:invalidArgument', 'Invalid position vector')
end

%smooth
if ~all( smooth_options.kernel==0 )
    est = smoothn( est, smooth_options.kernelwidth, [1 1], ...
        'nanexcl', smooth_options_fixed.nanexcl, 'correct', smooth_options_fixed.correct, ...
        'kernel', smooth_options.kernel, 'normalize', smooth_options_fixed.normalize);
end

%radon
[R, nn, settings] = padded_radon( est, radon_options{:});

%find max
%in the case of a plateau (e.g. if the estimate matrix is small, with nearest
%neighbor interpolation and "perfect" input (i.e. 0/1s)), the max function
%won't give the right answer, rather it will return the first max it finds.
%TODO: fix this?
[score, idx] = max( R(:) );
[idx(1) idx(2)] = ind2sub( size(R), idx );

thetamax = settings.theta( idx(1) );
rhomax = settings.rho( idx(2) );

score = score ./ size(est,2);

if nargout>3
    projection = padded_projection( est, thetamax, rhomax, radon_options{:} );
end

dt = mean( diff( x ) );
dp = mean( diff( y ) );

theta = atan( tan( thetamax ) .* dt./dp );
rho = rhomax .* dt .* cos(theta)./cos(thetamax);

slope = -cot( theta );
intercept = rho ./ sin(theta) - slope.*0.5*(x(1)+x(end)) + 0.5*(y(1)+y(end));