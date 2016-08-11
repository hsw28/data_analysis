function [new_cdat,stdev_cdat,indiv_traces] = gh_simple_trig(cdat,trigs,varargin)

p = inputParser();
p.addParamValue('window_length',0.02);
%p.addParamValue('memory_limit',1e7);
p.parse(varargin{:});
opt = p.Results;

ts = conttimestamp(cdat);
dt = diff(ts(1:2));

trigs = trigs(and(trigs > (min(ts)+opt.window_length/2), trigs < max(ts)-opt.window_length/2));

n_trig = numel(trigs);
n_chan = size(cdat.data,2);
n_samp = size(cdat.data,1);
n_total_samp = n_chan * n_samp;

trig_ind = histc(trigs, [ts(1)-dt/2, ts + dt/2]);
trig_log = logical(trig_ind(1:end-1));
trig_ind = find(trig_log);

n_new_ts_beyond_zero = ceil(opt.window_length/2 / dt);
n_new_ts = n_new_ts_beyond_zero*2 + 1;

new_ind = -n_new_ts_beyond_zero:n_new_ts_beyond_zero;
new_ts = new_ind .* dt;

%if( n_trig*n_total_samp < opt.memory_limit)
    % use repmat
    
    
%else
    % build trig eeg one bin at a time
    
% for now, build up indiv traces one trig at a time
indiv_traces = zeros(n_new_ts, n_chan, n_trig);
for n = 1:n_trig
    indiv_traces(:,:,n) = cdat.data(new_ind' + trig_ind(n),:);
end

new_cdat = cdat;
new_cdat.data = mean(indiv_traces,3);
new_cdat.tstart = min(new_ts);
new_cdat.tend = max(new_ts);

stdev_cdat = new_cdat;
stdev_cdat.data = std(indiv_traces,1,3);