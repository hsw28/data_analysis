function psth = psth_in_windows(events,triggers,wins,varargin)

p = inputParser();
p.addParamValue('timewin',[-1,1]);
p.addParamValue('smooth_secs',0.01);
p.addParamValue('samplerate',500);
p.parse(varargin{:});
opt = p.Results;

events   = reshape(gh_points_in_segs(events,wins),1,[]);
triggers = reshape(gh_points_in_segs(triggers,wins),[],1);

tOffset = bsxfun(@minus, events, triggers);

tOffset = reshape(tOffset,1,[]);
tOffset = tOffset(tOffset >= min(opt.timewin) & tOffset <= max(opt.timewin));

nTs = floor(diff(opt.timewin)*opt.samplerate);
if(mod(nTs,2) == 2)
    nTs = nTs+1;
end
ts = linspace(min(opt.timewin),max(opt.timewin),nTs);
dt = ts(2) - ts(1);

binEdges = bin_centers_to_edges(ts);

r = histc(tOffset,binEdges)./numel(triggers)./dt;
r = r(1:(end-1));

psth.r = r;
psth.ts = ts;
% 
% supportTimewin = [min(opt.timewin)+min([min(events),min(triggers)]),...
%     max(opt.timewin) + max([max(events),max(triggers)])];
% 
% ts = linspace(min(opt.timewin),max(opt.timewin),nTs);
% 
% pointRate = @(x) ksdensity(x, 'npoints', nTs, 'support', supportTimewin,...
%     'width',opt.smooth_secs);
% 
% eventRate    = pointRate(events);
% triggersRate = pointRate(triggers);
% 
% r = conv(eventRate,triggersRate,'same');