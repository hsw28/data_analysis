function f = ripplesDipsTime(mua, timewin, dt, smoothSec, state, trode_groups)

f = figure('units','inches','position',[22 2 4 6],'menu','none');

mua = sdatslice(mua,'timewin',timewin);

[~,muaRate] = assign_rate_by_time(mua,'samplerate',100);

hpcRate = eegByArea(muaRate,trode_groups,'HPC');
hpcRate.data = mean(hpcRate.data,2);

rscRate = eegByArea(muaRate,trode_groups,'RSC');
rscRate.data = mean(rscRate.data,2);

ripples = ripplesFromMUARate(hpcRate,'peakStdevBeyondMean',3);
[dips,~] = find_dips_frames(rscRate);

rippleTimes = reshape(cellfun(@(x) x(1), ripples),1,[]);
dipTimes    = reshape(cellfun(@(x) x(1), dips),1,[]);

stillBouts = gh_intersection_segs(state('still'), {timewin});

ts = timewin(1):dt:timewin(2);
edges = bin_centers_to_edges(ts);

rippRate = myKS(rippleTimes,edges,smoothSec);
dipRate  = myKS(dipTimes,   edges,smoothSec);

centerWidth = 0.2;

myPatch(ts,rippRate,centerWidth,[0 0 1]);
hold on;
myPatch(ts,dipRate,-1*centerWidth,[0 0.7, 0]);

cellfun(@(x) drawSeg(x,centerWidth), stillBouts);

xlim([-5 5])

set(gca,'YDir','reverse');
set(gcf,'Color',[1 1 1]);
set(gca,'Box','off');
set(gca,'XTick',[]);
set(gca,'XColor',[1 1 1]);
%set(gca,'YColor',[1 1 1]);

end

function drawSeg(seg,wid)
if(diff(seg) > 5)
xs = [-1,-1,1,1,-1] .* wid;
ys = seg([1,2,2,1,1]);
patch( xs,ys, [0.5 0.2 0.01], 'EdgeColor','none' );
end
end

function ys = myKS(xs,edges,nSmooth)
dt = edges(2) - edges(1);
ys = histc(xs,edges);
ys = smooth(ys(1:(end-1)),nSmooth)' ./ dt;
end

function myPatch(t,y,d,c)

patch([y,y(1)]*sign(d)+d,[t,t(1)],c,'EdgeColor','none')

end