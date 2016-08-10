function fs = retreat_hector(varargin)

p = inputParser();
p.addParamValue('day1dir','~/Data/blue/032813');
p.addParamValue('day2dir','~/Data/matlabbed/blue/032213');

p.addParamValue('day1eeg',[]); 
p.addParamValue('day1mua',[]);
p.addParamValue('day1rscChan',{'19','18','16','21'});  % '15','14','13','11'
p.addParamValue('day1ctxChan',{'05','03','04','06'});

p.addParamValue('day2eeg',[]); % TODO
p.addParamValue('day2mua',[]); % TODO
p.addParamValue('day2rscChan',{'19','18','16','21'});
p.addParamValue('day2hpcChan',{'01','02','03','04'});

p.addParamValue('day1TimewinLowMag',[1720,1735]);
p.addParamValue('day1TimewinHighMag',[1727 1731]); % TODO

p.addParamValue('day2TimewinLowMag',[5875 5890]);
p.addParamValue('day2TimewinHighMag',[5882 5887]);

p.addParamValue('rscColor',[0.7 0 0]);
p.addParamValue('ctxColor',[0 0.6 0]);
p.addParamValue('hpcColor',[0   0 0.6]);

p.addParamValue('eegSpacing',1);
p.addParamValue('flipEEG',true);

p.parse(varargin{:});
opt = p.Results;

% Three figures:
% 1: Sleep Cortex and other-cortex, zoomed out
% 2: Sleep Cortex and other-cortex, zomed in
% 3: Sleep Cortex and hpc: zoomed in to show not-locked-together ripps and dips

startDir = pwd();


% Day1: FIGURE 1 and 2
cd(opt.day1dir);

if(isempty(opt.day1eeg))
load eeg.mat
else
eeg = opt.day1eeg;
end

if(isempty(opt.day1mua))
load mua.mat
else
mua = opt.day1mua;
end

if(opt.flipEEG)
    eeg.data = -1 .* eeg.data;
end

lfun_plot(eeg,mua,'RSC',opt.rscColor,opt.day1rscChan,'CTX',opt.ctxColor, opt.day1ctxChan, opt.day1TimewinLowMag,blue_trode_groups('date','032813'),opt,true);
lfun_plot(eeg,mua,'RSC',opt.rscColor,opt.day1rscChan,'CTX',opt.ctxColor, opt.day1ctxChan, opt.day1TimewinHighMag,blue_trode_groups('date','032813'),opt,true);

% Day2
cd(opt.day2dir);

if(isempty(opt.day2eeg))
load eeg.mat
else
eeg = opt.day2eeg;
end

if(isempty(opt.day2mua))
load mua.mat
else
mua = opt.day2mua;
end

if(opt.flipEEG)
    eeg.data = -1 .* eeg.data;
end

lfun_plot(eeg,mua,'RSC',opt.rscColor,opt.day2rscChan,'HPC',opt.hpcColor, opt.day2hpcChan,opt.day2TimewinLowMag,blue_trode_groups('date','032213'),opt,false);
lfun_plot(eeg,mua,'RSC',opt.rscColor,opt.day2rscChan,'HPC',opt.hpcColor, opt.day2hpcChan,opt.day2TimewinHighMag,blue_trode_groups('date','032213'),opt,false);


cd(startDir);

end



function G = lfun_plot(eeg,mua,groupA,colorA,eegChanA,groupB,colorB,eegChanB,timewin,trode_groups,opt,datTogether)

% Make figure 11x8.5 inches
G = figure('units','inches','position',[22 1 11 8.5],'menu','none');
%subs = struct('region',{'rsc','rsc','rsc','ctx','ctx','ctx'}, ...
%              'data',  {'lfp','mRate','mRaster','lfp','mRate','mRaster'}, ...
%              'color', {[0.7 0 0], [0.7 0 0], [0.7 0 0], [0 0.6 0], [0 0.6 0],[0 0.6 0]});
%lfun_plot(eeg,mua,opt.day1TimewinLowMag,f,subs,blue_trode_groups('date','032813'))
nSub = 6;

if datTogether
aInd = [1,2,3,6,5,4] + 1;
else
aInd = (1:6) + 1;
end

gpAB = cellfun( @(x) strcmp(x.name,groupA),trode_groups );
gpAG = trode_groups{gpAB};
gpAChans = gpAG.trodes;
gpAChans = gpAChans ( cellfun(@(x) numel(x) < 3, gpAChans )); % drop chans w/ long names

gpBB = cellfun(@(x) strcmp(x.name,groupB), trode_groups);
gpBG = trode_groups{gpBB};
gpBChans = gpBG.trodes;
gpBChans = gpBChans (cellfun(@(x) numel(x) < 3, gpBChans )); % drop chans w/ long names

buf = 10;
thisAeeg = contchans(contwin(eeg,timewin + [-buf,buf]),'chanlabels',eegChanA);
thisBeeg = contchans(contwin(eeg,timewin + [-buf,buf]),'chanlabels',eegChanB);
thisAmua = sdatslice(mua,'timewin',timewin + [-buf,buf],'trodes',gpAChans);
thisBmua = sdatslice(mua,'timewin',timewin + [-buf,buf],'trodes',gpBChans);

ts = conttimestamp(thisAeeg);

plotEdges = linspace(1-0.0325,0.0325, 7);
plotHeight = plotEdges(1) - plotEdges(2);
plotWidth = 0.94;

a = aInd(1);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
s = smoothCdat(thisAeeg);
nChan = size(thisAeeg.data,2);
plot(ts,bsxfun(@plus, thisAeeg.data, [1:nChan]*opt.eegSpacing),'-','Color',colorA);
ylim([0,nChan+1]*opt.eegSpacing);
lfun_condition(ax(a));

a = aInd(2);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
r = lfun_rate(thisAmua,ts,0.020);
area(ts,r,0,'FaceColor',colorA,'LineStyle','none');
ylim([0,.15]);
lfun_condition(ax(a));

a = aInd(3);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
plot_raster(thisAmua,colorA);
lfun_condition(ax(a));


a = aInd(4);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
s = smoothCdat(thisBeeg);
nChan = size(thisBeeg.data,2);
plot(ts,bsxfun(@plus,thisBeeg.data,[1:nChan]*opt.eegSpacing),'-','Color',colorB);
ylim([0,nChan+1] * opt.eegSpacing);
if datTogether
set(ax(a),'YTick',[]);
else
lfun_condition(ax(a));
end

a = aInd(5);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
r = lfun_rate(thisBmua,ts,0.020);
ylim([0,100]);
area(ts,r,0,'FaceColor',colorB,'LineStyle','none');
lfun_condition(ax(a));


a = aInd(6);
ax(a) = axes('parent',G,'Position',[0.03,plotEdges(a),plotWidth,plotHeight]);
plot_raster(thisBmua,colorB);
if ~datTogether
set(ax(a),'YTick',[]);
else
lfun_condition(ax(a));
end

linkaxes(ax,'x');
xlim(timewin);


end

function newCdat = smoothCdat(cdat)
newCdat = cdat;
nChan = size(cdat.data,2);
for n  =  1:nChan
newCdat.data(:,n) = smooth(newCdat.data(:,n), 5);
end
end

function lfun_condition(ax)
set(ax,'XTick',[]);
set(ax,'YTick',[]);
end

function plot_raster(sdat,color)
for c = 1:numel(sdat.clust)
[xs,ys] = gh_raster_points(sdat.clust{c}.stimes);
plot(xs,ys+c,'-','Color',color);
hold on
end
ylim([1,numel(sdat.clust)]);
end

function r = lfun_rate(sdat, ts, smooth)
spikes = sort( foldl(@(x,y) [x,y.stimes], [], sdat.clust) );
r = ksdensity(spikes, ts, 'width',smooth);
end
