function s = velocity_state(vel_cdat, pos_info, epochMap, varargin)
% velocity_state( allTimeVelocity, posInfo, epochMap, optionalArgs )

p = inputParser();
p.addParamValue('stillThresh',0.2);
p.addParamValue('absolutelyStillThresh',0.2);
p.addParamValue('interuptiveMovementMinWidth',0.05);
p.addParamValue('stillMinWidth',0.5);
p.addParamValue('absolutelyStillMinWidth',0.5);
p.addParamValue('runningThresh',0.2);
p.addParamValue('runningMinWidth',0.5);
p.addParamValue('maxBridge',0.5);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

%if(~isempty(pos_info))
%    track_ts = conttimestamp(pos_info.lin_vel_cdat);
%    vel_ts = conttimestamp(vel_cdat);
%    replaceBool = vel_ts >= min(track_ts) & vel_ts <= max(track_ts);
%    vel_cdat.data(replaceBool) = ...
%        interp1(track_ts, pos_info.lin_vel_cdat.data, vel_ts(replaceBool),'linear');
%end

outbound_criterion = seg_criterion('name','outbound','bridge_max_gap', opt.maxBridge,...
    'cutoff_value',opt.runningThresh,'min_width_post_bridge',opt.runningMinWidth);

inbound_criterion  = seg_criterion('name','inbound', 'bridge_max_gap', opt.maxBridge,...
    'cutoff_value',-1* opt.runningThresh,'min_width_post_bridge',opt.runningMinWidth,...
    'threshold_is_positive', false, 'bridge_max_gap', opt.maxBridge);

interruptive_criterion = seg_criterion('name','interruptive','bridge_max_gap',opt.maxBridge,...
    'cutoff_value', opt.stillThresh, 'min_width_post_bridge',opt.absolutelyStillMinWidth);

still_criterion  = seg_criterion('name','still', 'bridge_max_gap',opt.maxBridge,...
    'cutoff_value',opt.stillThresh,'threshold_is_positive',false,'min_width_post_bridge',opt.stillMinWidth);

absolutely_still_criterion = seg_criterion( 'cutoff_value', opt.absolutelyStillThresh, ...
    'min_width_pre_bridge',opt.stillMinWidth, 'threshold_is_positive',false,...
    'bridge_max_gap',opt.maxBridge);

allEpochs = epochMap.values;
allEpochs = foldl( @gh_union_segs, cell(0), allEpochs );

absVelCdat = vel_cdat;
absVelCdat.data = abs(absVelCdat.data);

% Why are there all these intersections?  b/c only keep times in a labeled epoch
s.outbound = gh_intersection_segs(gh_signal_to_segs(pos_info.lin_vel_cdat,outbound_criterion,'draw',false), ...
    allEpochs);

s.inbound  = gh_intersection_segs(gh_signal_to_segs(pos_info.lin_vel_cdat,inbound_criterion), ...
    allEpochs);

s.interruptive = reshape(gh_signal_to_segs(absVelCdat, interruptive_criterion), 1,[]);

s.still  = gh_intersection_segs(gh_signal_to_segs(absVelCdat,still_criterion), ...
    allEpochs);
s.still = gh_subtract_segs(s.still, s.interruptive);
s.still = filterCell(@(x) diff(x) >= opt.stillMinWidth, s.still);


s.running = gh_intersection_segs(gh_union_segs( s.outbound,s.inbound ), ...
    allEpochs);

s.absolutelyStill = gh_intersection_segs( ...
    gh_signal_to_segs(absVelCdat, absolutely_still_criterion), allEpochs);
s.absolutelyStill = gh_subtract_segs(s.absolutelyStill, s.interruptive);
s.absolutelyStill = filterCell(@(x) diff(x) >= opt.absolutelyStillMinWidth, s.absolutelyStill);

if(opt.draw)    
    gh_draw_segs({s.outbound, s.inbound, s.running, s.still,s.absolutelyStill}, 'names',{'outbound','inbound','running','still','absolutelyStill'}, 'ys', {[-1 0], [-2,-1], [-3,-2], [-4,-3],[-5 -4]});
    hold on;
    gh_plot_cont(vel_cdat);
end