function si = spatialinfo( spike_prob, occupancy_prob, xlimits, tol )
%SPATIALINFO calculate spatial information
%
%  Syntax
%
%      si = spatialinfo( spike_probability, occupancy_probability [, xlimits, tol])
%
%  Description
%
%    This function will calculate the spatial information of a spike train.
%    The argument spike_prob is a vector of spike probabilities for a set
%    of bins; argument occupancy_prob is the probability that the animal
%    can be found in each bin. Alternatively spike_prob and occupancy_prob
%    can be handles to function that calculate the probability density as a
%    function of x. In this case, the xlimits is required to set the lower
%    and upper boundaries of x. Optionally the tolerance for calculation of
%    the integral can bet set (default = 1e-5).
%

%  Copyright 2005-2006 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if isnumeric(spike_prob) && isnumeric(occupancy_prob)
  
  if isscalar( occupancy_prob )
    occupancy_prob = zeros( size( spike_prob ) ) + occupancy_prob;
  end
  
  %make sure probabilities sum to 1
  spike_prob = spike_prob ./ nansum(spike_prob);
  occupancy_prob = occupancy_prob ./ nansum(occupancy_prob);
  
  valid = spike_prob~=0 & ~isnan( spike_prob ) & ~isnan( occupancy_prob );
  si = sum( spike_prob(valid) .* log2( spike_prob(valid) ./ occupancy_prob(valid) ) );
  
elseif isa(spike_prob, 'function_handle') && isa(occupancy_prob, 'function_handle')
  
  if nargin<3
    error('X limits needed')
  end
  
  if nargin<4
    tol = 1.e-5;
  end
  
  %make sure probabilities sum to 1
  ss = nanquad( spike_prob, xlimits(1), xlimits(2), tol );
  so = nanquad( occupancy_prob, xlimits(1), xlimits(2), tol );
  
  warning('off', 'MATLAB:log:logOfZero');
  warning('off', 'MATLAB:quad:ImproperFcnValue');
  si = nanquad( @(x) (spike_prob(x)./ss) .* log2( so.*spike_prob(x)./( ...
      occupancy_prob(x).*ss ) ), xlimits(1), xlimits(2), tol );
  warning('on', 'MATLAB:log:logOfZero');
  warning('on', 'MATLAB:quad:ImproperFcnValue');
  
else   
  error( 'Combination of vector and function handle is not supported' )    
end



% if isscalar(p)
%     p = zeros( size(f) ) + p;
% end
% 
% meanf = nansum( p .* f );
% valid = ( f~=0 & ~isnan(f) & ~isnan(p) );
% si = sum( p(valid).*f(valid).*log2(f(valid)/meanf)./meanf );