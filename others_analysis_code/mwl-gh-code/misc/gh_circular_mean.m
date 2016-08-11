function circ_mean = gh_circular_mean(t,varargin)
% circ_mean = GH_CIRCULAR_MEAN(t, ['weights',weights],['dim',1],
%                                 ['output_range', [0, 2*pi]] );
%    acts the same as 'mean()' but cicrularly
%    -data are grouped by 'dim' argument; default return on a matrix is a
%    row vector
%    -'weights' can change the relative importance of each value in t.
%    -'output_range' must diff to 2*pi
% X should be a vector or array of thetas
% CLEAN UP AND DOCUMENT THIS GREG, YEESH!

p = inputParser;
p.addParamValue('weights',ones(size(t)));
p.addParamValue('dim', 1);
p.addParamValue('output_range',[-pi, pi], @(d) abs(diff(d)-2*pi) < 1e-100);
p.parse(varargin{:});

x = cos(t) .* p.Results.weights;
y = 1i*sin(t) .* p.Results.weights;

z_hat = sum(x,p.Results.dim) + sum(y,p.Results.dim);

circ_mean = angle(z_hat);  %NB: angle range is -pi,pi

% put mean into the 0,2pi range
circ_mean = mod(circ_mean,2*pi);

% put mean into the p.Results.range
circ_mean = mod((circ_mean - p.Results.output_range(1)), 2*pi) + p.Results.output_range(1);