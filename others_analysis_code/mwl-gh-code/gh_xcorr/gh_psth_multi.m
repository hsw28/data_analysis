function [counts, bin_centers] = gh_psth_multi(triggers,spikes,varargin)

% fix this to take an sdat

p = inputParser();
p.addParamValue('counts_units','counts',@(x) any(strcmp(x,{'counts','binned_rates','smoothed_rates','times'})));
p.addParamValue('window_length',2); % seconds
p.addParamValue('bin_length',0.001);  % seconds
p.addParamValue('spike_smooth_sd',0.001); % seconds to gaussian smooth spikes
p.addParamValue('bouts', [], @(x) size(x,1) == 2); % want 2 x n intervals list
p.addParamValue('memory_limit',1e7);
p.parse(varargin{:});
opt = p.Results;

% easiest way to deal with bound colisions with triggers' bin edges, etc
% is to drop all triggers that are outside use-bounds, or inside
% but near the edges of use bounds

keep_log = zeros(1,numel(triggers));
for n = 1:size(opt.bouts,2)
    keep_log(and(triggers > opt.bouts(1,n), triggers < opt.bouts(2,n))) = 1;
end
triggers = triggers(keep_log);
