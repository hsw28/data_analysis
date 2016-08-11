function seg = gh_signal_to_segs(cdat, seg_crit, varargin)

p = inputParser();
p.addParamValue('draw',false);
p.addParamValue('draw_vs_default',false); % What is this supposed to do?
p.parse(varargin{:});
opt = p.Results;

n_chans = size(cdat.data,2);
if(n_chans > 1)
    warning('gh_signal_to_segs:multiple_channels',...
        'Multiple input channels.  Keeping only the first');
    cdat = contchans(cdat,'chans',1);
end

d = reshape(cdat.data, 1,[]);
ts = conttimestamp(cdat);
dt = ts(2) - ts(1);

if(seg_crit.threshold_is_positive)
    cmp = @ge;
    anticmp = @lt;
    extreme = @max;
    antiextreme = @min;
else
    cmp = @le;
    anticmp = @gt;
    extreme = @min;
    antiextreme = @max;
end

starts = find( [diff( cmp( d, seg_crit.cutoff_value )) ==  1, 0] );
stops  = find( [diff( cmp( d, seg_crit.cutoff_value )) == -1, 0] ) + 1;
if(numel(starts) > 0 && numel(stops) > 0)
    if(stops(1) < starts(1))
        stops(1) = [];
    end
    if(starts(end) > stops(end))
        starts(end) = [];
    end
end
    
% Now every start should have a corresponding stop, and all starts
% should preceed their stop.  
assert( numel(starts) == numel(stops) );
assert( all( stops > starts ) );

% First-pass windows
s = mat2cell( [starts',stops'], ones(numel(starts),1), 2);

% Filter them by whether their peak is high enough
if(~isempty(seg_crit.peak_min))
    s = s(cellfun(@(x) cmp(extreme(d(x(1):x(2))), seg_crit.peak_min), s));
end

% Filter them by whether they are long enough
keep_bool = cellfun(@(x) dt*diff(x) >= seg_crit.min_width_pre_bridge, s);
s = s(keep_bool);

% Bridge close-enough neighbors
s = gh_bridge_segs(s, seg_crit.bridge_max_gap / dt ,'draw',false);

%  Filter the bridged ones by whether bridged are long enough
keep_bool = cellfun(@(x) dt*diff(x) >= seg_crit.min_width_post_bridge, s);
s = s(keep_bool);

% Split segs with an 'adequate local min'
if(~isempty(seg_crit.adequate_local_min))
    minPeakDistSamps = seg_crit.min_peak_dist * cdat.samplerate;
    s = gh_split_segs_at_trough(d,s,seg_crit.adequate_local_min, anticmp, antiextreme,minPeakDistSamps,seg_crit.peak_min);
end

seg = cellfun(@(x) [ts(x(1)), ts(x(2))], s,'UniformOutput',false);





if(opt.draw)
    if(~opt.draw_vs_default)
        draw_segs = {seg}
        draw_segs_y = {[min(d), max(d)]};
        names     = 'segs';
    else
        default_seg_crit = seg_criterion('peak_min', seg_crit.peak_min, 'cutoff_value', seg_crit.cutoff_value);
        s_def = gh_signal_to_segs(cdat, default_seg_crit, 'draw',false);
        draw_segs     = {s_def, s};
        names         = {'default', 'actual'};
    end
    gh_draw_segs(draw_segs, 'names', names); hold on;
    plot(conttimestamp(cdat), d);
end
end