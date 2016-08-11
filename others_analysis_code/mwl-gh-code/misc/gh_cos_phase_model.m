function varargout = gh_cos_phase_model(varargin)
% GH_COS_PHASE_MODEL - fits a rate offset sinwave to binned phase counts
%
% fit a cos wave to a circularly distributed random variable
% inputs can be either
% A:  a vector of phases.  These will be converted to circular histogram
%     with n_bins bins (defined in the function)  OR
% B:  a vector of circular histogram bin centers AND counts for those bins
%
% Outputs:
% [phase_pref, mod_depth]
% [phase_pref, mod_depth, p_value]
% [phase_pref, mod_depth, p_value, bin_centers, bin_vals]
% 
% phase_pref -         the preferred phase
% mod depth -          the value (peak - trough) / peak.  Varies between 1 and 0,
%                      for complete modulation and no modulation respectively.
% p_value (optional) - Rayliegh test of the mean resultant vector
% bin_centers  (opt) - the bin centers from the circular hist computed
% bin_vals     (opt) - values of the circular hist

% debug flag
debug_it = false;

% if we have to make a circular histogram, use this many bins
n_bins_for_circ_hist = 24;

% check input, assign input variables
for n = 1:length(nargin)
    if(any(isnan(varargin{n})))
        warning('gh_cos_wave_model:input_nan','NaN in input.  Plz check phases.');
    end
end

if(nargin == 1)
    raw_input = true;
    raw_phases = varargin{1};
    phase_range = max(raw_phases) - min(raw_phases);
    if(phase_range > 2*pi)
        warning('gh_cos_phase_model:bad_phase_range','Raw phases vary over greater than 2*pi');
    end
    % input phases may be in -pi:pi.  Change this to 0:2*pi
    raw_phases = mod(raw_phases,2*pi);
elseif(nargin == 2)
    raw_input = false;
    bin_centers = varargin{1};
    bin_vals = varargin{2};
    phase_range = max(bin_centers) - min(bin_centers);
    if(phase_range > 2*pi)
        warning('gh_cos_phase_model:bad_phase_range','Phase bins vary over greater than 2*pi');
    end
    bin_centers = mod(bin_centers, 2*pi);
else
    error('gh_cos_phase_model:wrong_in_arg_count','Use either ([a vector of phases]), or ([a vector of bin centers], [vector of counts in those bins])');
end   

% set up the circular histogram
if(raw_input)
    bin_edges = linspace(0,2*pi,n_bins_for_circ_hist + 1);
    bin_centers = mean([bin_edges(1:end-1); bin_edges(2:end)]);
    bin_vals = histc(raw_phases,bin_edges);
    if(bin_vals(end) > 0)
        error('gh_sin_phase_model:fail_circ_hist_sanity_check','Unexpected hist counts in bin phase > 2*pi');
    end
    bin_vals = bin_vals(1:end-1); % drop the final catch-bin
end

% calculate mean resultant vector, z_mag, z_arg, and p-value
% p value comes from rayleigh statistic, see Siapas, Lubenov, Wilson 2005
if(raw_input)
    m = mean(cos(raw_phases) + i*sin(raw_phases));
    n_for_p = length(raw_phases);
else
    m = mean(bin_vals.*cos(bin_centers) + i.*bin_vals.*(bin_centers));
    n_for_p = length(bin_centers);
end
mag = abs(m);
arg = angle(m);

% here n_for_p is either the number of raw phases, or the number of phase
% bins, depending on the input given.  I need to make sure that the p value
% and Z statistic are really computed this way in the case of binned data
% (or more generally in the case of non-uniform-magnitude draws)
Z = n_for_p * mag;
if(n_for_p < 50)
    p_value = exp(-1*Z) * (1 + (2*Z - Z^2)/(2*n_for_p) - (24*Z - 132*(Z^2) + 76*(Z^3) - 9*(Z^4)) / (288 * (n_for_p^2)) );
else
    p_value = exp(-1*Z);
end

% use non-linear regression to fit a y-offset sin wave over the bin vals
offset_0 = mean(bin_vals);
mu_0 = arg;
A_0 = (max(bin_vals) - min(bin_vals)) / 2;
b_0 = [A_0, mu_0, offset_0];
%betahat = nlinfitsome([true, true, true],bin_centers',bin_vals,@lfun_offset_cos_model,b_0);
betahat = nlinfit(bin_centers',bin_vals,@lfun_offset_cos_model,b_0);
phase_pref = betahat(2);
A_hat = betahat(1);
offset_hat = betahat(3);
mod_depth = 2*A_hat/(offset_hat + A_hat); % after some arithmetic
% peak is A + offset; trough is offset - A.  Modulation is
% (peak-tough)/peak
% so ( (A + offset) - (offset - A) ) / (A + offset)  =  2A / (A + offset)

varargout{1} = phase_pref;
varargout{2} = mod_depth;

if(nargout == 2)
    % ok
elseif(nargout == 3)
    varargout{3} = p_value;
elseif(nargout == 5)
    varargout{3} = p_value;
    varargout{4} = bin_centers;
    varargout{5} = bin_vals;
else
    error('gh_cos_phase_model:wrong_output_count','Wrong number of output arguments.  Please see help gh_cos_phase_model');
end

if(debug_it)
    bar(bin_centers,bin_vals);
    hold on;
    x = linspace(0,2*pi,100);
    plot(x,lfun_offset_cos_model(betahat,x)');
end

% define the mean-offset sin wave function for nonlinear regression to
% check against
function y_hat = lfun_offset_cos_model(beta,x)
% beta must have 3 parameters: A, mu, and offset
% x should be 1 column wide.  A series of phases at which to evaluate the
% function (namely, the phase bin centers)
% NB - this function assumes a 2*pi frequency
freq = 2*pi;
A = beta(1);
mu = beta(2);
offset = beta(3);
y_hat = A*cos( (2*pi/freq) .* x - mu) + offset;