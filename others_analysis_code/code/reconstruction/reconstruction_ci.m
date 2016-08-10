function ci = reconstruction_ci(r_pos_array,varargin)

p = inputParser();
p.addParamValue('bounds',0.95);
p.parse(varargin{:});
opt = p.Results;

n_pdf = numel(r_pos_array);
n_ts = size(r_pos_array(1).pdf_by_t,2);
n_pos = size(r_pos_array(1).pdf_by_t,1);

ci = zeros(2,n_ts,n_pdf);
p_limits = 0.5 + opt.bounds/2 .* [-1, 1];

%pos_vals = r_pos_array(1).x_vals;

d_pos = r_pos_array(1).x_vals(2) - r_pos_array(1).x_vals(1);
pos_vals = r_pos_array(1).x_vals;
pos_vals = [min(pos_vals) - d_pos; pos_vals];
big_pos_array = repmat(pos_vals,1,n_ts);
%max_pos = max(r_pos_array(1).x_vals);
%pos_vals = linspace(0, max_pos + d_pos/2, n_pos+1);

%pos_at_mode = reconstruction_pos_at_mode(r_pos_array);

for n = 1:n_pdf
    
    this_pdf = r_pos_array(n).pdf_by_t;
    this_pdf = [zeros(1,n_ts);this_pdf];
    
    this_cdf = cumsum(this_pdf,1);
    
    slopes_here_to_next = this_pdf ./ d_pos;
    slopes_here_to_next = [slopes_here_to_next(1:(end-1),:); zeros(1,n_ts)];
    
    tmp = (p_limits(1) >= this_cdf);
    tmp2= (p_limits(1) <  [this_cdf(2:end,:); logical(zeros(1,n_ts))]);
    highest_prob_before_low_thresh_b = and(tmp,tmp2);
    
    tmp = this_pdf;
    tmp(~highest_prob_before_low_thresh_b) = NaN;
    highest_prob_before_low = min(tmp,[],1);
    
    tmp = big_pos_array;
    tmp(~highest_prob_before_low_thresh_b) = NaN;
    pos_at_highest_prob_before_low = min(tmp,[],1);
    
    tmp = slopes_here_to_next;
    tmp(~highest_prob_before_low_thresh_b) = NaN;
    this_slopes = min(tmp,[],1);
    
    prob_dists = p_limits(1) - highest_prob_before_low;
    
    extra_dist = min((prob_dists ./ this_slopes), d_pos*ones(size(prob_dists)));
    ci_lower = pos_at_highest_prob_before_low + extra_dist;
    
    tmp  = (p_limits(2) >= this_cdf);
    tmp2 = p_limits(2) < [this_cdf(2:end,:); logical(zeros(1,n_ts))];
    highest_prob_before_high_thresh_b = and(tmp,tmp2);
    
    tmp = big_pos_array;
    tmp(~highest_prob_before_high_thresh_b) = NaN;
    pos_at_highest_prob_before_high = min(tmp,[],1);
    
    tmp = this_pdf;
    tmp(~highest_prob_before_high_thresh_b) = NaN;
    highest_prob_before_high = min(tmp,[],1);
    
    prob_dists = p_limits(2) - highest_prob_before_high;
    
    extra_dist = min((prob_dists ./ this_slopes), d_pos*ones(size(prob_dists)));
    ci_higher = pos_at_highest_prob_before_high + extra_dist;
    
    ci(:,:,n) = [ci_lower; ci_higher];
end