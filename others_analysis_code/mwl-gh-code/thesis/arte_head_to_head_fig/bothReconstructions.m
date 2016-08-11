function f = bothReconstructions()

% TODO - get rid of pre-computed stuff as much as possible
%        or at least make this usable by others w/ the .mat data files
load('/home/greghale/Documents/RetroProject/otherDocuments/rawFigs/decoding.mat');
m = caillou_112812_metadata();

exampleDataPath = '/home/greghale/Data/caillou/112812/rposExampleData.mat';
if(~exist(exampleDataPath))
    error('bothReconstructions:noExmapleData',['Run reconstruction_fig to build the ', ...
        'right example data (with different click-points to adjust the track seam.']);
else
    load(exampleDataPath);
end

arteNDecodings = size(decoding,2);
arteNSpatialBins = size(decoding,1);
arteRTau = 0.02;
arteTSStart = 4492.0;
arteTSGoal = [arteTSStart:0.020:9000];
arteTs = ts;
arteTSGoal = arteTSGoal(1:numel(arteTs));

shiftBy = arteNSpatialBins-1;
decoding = decoding([shiftBy+1:arteNSpatialBins,1:shiftBy],:);

d.tg = m.trode_groups_fn('date',m.today,'segment_style','areas');
d.tg = d.tg( strcmp( cmap(@(x) x.name, d.tg), 'CA1') );
d.tg{1}.color = [1 1 1];

rpos = gh_decode_pos(d.spikes,d.pos_info,'r_tau',0.02,'field_direction','outbound');
rpos_ts = linspace(rpos.tstart,rpos.tend,size(rpos.pdf_by_t,2));

exampleTimewins = [4620,4640; ...  % early run stretch
                   5601,5608; ...  % late run stretch
                   5131,5132; ...  % theta sequences
                   4882,4883];   % replay

for n = 1:size(exampleTimewins,1)
    plotBoth(decoding,ts,rpos.pdf_by_t,rpos_ts,...
        d.pos_info,n,exampleTimewins,arteTSGoal,arteTs);
end

end

function plotBoth(rpTop,tsTop, rpBot, tsBot, pos_info, ind, timewins,tsGoal,ts)
    xRange = [0,3.5828];
    nTimewins = size(timewins,1);
    thisTimewin = timewins(ind,:);
    pos = contwin(pos_info.lin_cdat,thisTimewin);
    [tsTop,rpTop] = subImage(rpTop,   tsTop,thisTimewin);
    [tsBot,rpBot] = subImage(rpBot,tsBot,thisTimewin);
    [tsGoal,ts]   = subImage(tsGoal,ts,thisTimewin);
    subplot(2,nTimewins,ind);
    imagesc([min(tsTop),max(tsTop)],xRange,...
            rpTop.^1.5);
    set(gca,'YDir','normal');
    hold on;
    plot(conttimestamp(pos),pos.data,'w');
    subplot(2,nTimewins,ind+nTimewins);
    imagesc([min(tsBot),max(tsBot)],xRange,rpBot.^1.5);
    set(gca,'YDir','normal');
    hold on;
    plot(conttimestamp(pos),pos.data,'w');
    plot(tsGoal,ts-tsGoal);
end

function [ts,img] = subImage(imgIn,tsIn,timewin)
   nCols = size(imgIn,2);
   okInd = find(tsIn >= min(timewin) & tsIn <= max(timewin));
   if(min(okInd) > 1)
       okInd = [min(okInd)-1,okInd];
   end
   if(max(okInd) < nCols)
       okInd = [okInd, max(okInd)+1];
   end
   ts = tsIn(okInd);
   img = imgIn(:,okInd);
end