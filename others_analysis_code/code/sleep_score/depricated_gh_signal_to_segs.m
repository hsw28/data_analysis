function seg = gh_signal_to_segs(cdat, seg_crit, varargin)

p = inputParser();
p.addParamValue('draw',false);
p.addParamValue('draw_vs_default',false);
p.parse(varargin{:});
opt = p.Results;

n_chans = size(cdat.data,2);
if(n_chans > 1)
    warning('gh_signal_to_segs:multiple_channels',...
        'Multiple input channels.  Keeping only the first');
    cdat = contchans(cdat,'index',1);
end

if(seg_crit.thresh_is_positive)
    surp    = @ge;
    unsurp  = @le;
    extreme = @max;
else
    surp    = @le;
    unsurp  = @ge;
    extreme = @min;
end

d = reshape(cdat.data, 1,[]);
ts = conttimestamp(cdat);
dt = ts(2) - ts(1);

% Find samples at which cutoff-level is exceeded, then 
starts = find(diff( surp(d, seg_crit.cutoff_value) ) ==  1);
stops  = find(diff( surp(d, seg_crit.cutoff_value) ) == -1);

% Remove the first 'stop' if it happens before the first 'start'
if(stops(1) < starts(1))
    stops = stops(2:end);
end

% Remove the last 'start' if it happens after the last 'stop'
if(starts(end) > stops(end))
    starts = starts(1:(end-1));
end


% Now every start should have a corresponding stop, and all starts
% should preceed their stop.  
assert( numel(starts) == numel(stops) );
assert( all( stops > starts ) );

% First-pass windows
s = mat2cell( [starts',stops'], ones(numel(starts),1), 2);

% Filter them by whether their peak is high enough
if(~isempty(seg_crit.peak_min))
    s = s(cellfun(@(x) surp(extreme(d(x(1):x(2))), seg_crit.peak_min), s));
end

% Filter them by whether they are long enough
keep_bool = cellfun(@(x) dt*diff(x) >= seg_crit.min_width_pre_bridge, s);
s = s(keep_bool);

% Bridge close-enough neighbors
s = gh_bridge_segs(s, seg_crit.bridge_max_gap);

%  Filter the bridged ones by whether bridged are long enough
keep_bool = cellfun(@(x) dt*diff(x) >= seg_crit.min_width_post_bridge, s);
s = s(keep_bool);

seg = cellfun(@(x) [ts(x(1)), ts(x(2))], s,'UniformOutput',false);

if(opt.draw)
    plot(conttimestamp(cdat), d);
    if(~opt.draw_vs_default)
        draw_segs = {[min(d), max(d)]};
        names     = [];
    else
        default_seg_crit = seg_criterion('peak_min', seg_crit.peak_min, 'cutoff_value', seg_crit.cutoff_value);
        s_def = gh_signal_to_segs(cdat, default_seg_crit, 'draw',false);
        draw_segs     = {s_def, s};
        names         = {'default', 'actual'};
    end
    gh_draw_segs(draw_segs, 'names', names);
end
end