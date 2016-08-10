function [slope,intercept] = heatRegress(xLims,yLims,heats,varargin)
% This function is extremely specific to the theta sequence
% cross correlation

p = inputParser();
p.addParamValue('yRangeToFit',[-0.1,0.1]);
p.addParamValue('letterbox',20);
p.addParamValue('smooth',10);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

ys = linspace(min(yLims),max(yLims),size(heats,1));
xs = linspace(min(xLims),max(xLims),size(heats,2));

letterboxedHeats = heats;
letterboxedHeats(:,1:opt.letterbox)         = 0;
letterboxedHeats(:,(end-opt.letterbox:end)) = 0

yIndsToUse = find( ys >= opt.yRangeToFit(1) & ys <= opt.yRangeToFit(2));
ysToUse = ys(yIndsToUse);

xsAtYs = zeros(size(yIndsToUse));

for n = 1:numel(yIndsToUse)
    
    thisYs = smooth(letterboxedHeats(yIndsToUse(n),:), opt.smooth);    
    xsAtYs(n) = xs( find(max(thisYs) == thisYs, 1, 'first'));
    
end

b = regress(ysToUse',[xsAtYs',ones(size(xsAtYs'))]);
slope = b(1);
intercept = b(2);
xIntercept = -intercept/slope;

if(opt.draw)
    imagesc(xLims,yLims,heats);
    set(gca,'YDir','normal');
    hold on;
    plot(xsAtYs,ysToUse,'.');
    plot(xLims, xLims*b(1) + b(2));
end