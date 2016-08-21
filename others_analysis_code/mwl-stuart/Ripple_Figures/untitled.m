


E = cell2mat(eegSamps');
H = cell2mat(hpcSamps');
C = cell2mat(ctxSamps');

t1 = linspace( win(1), win(2), size(E,2));
t2 = linspace( win(1), win(2), size(H,2));

i = 1;
%% Plot MU Rate Examples
close all;
figure('Position', [2 402 700 700]);
get
for i = 1:size(E,1)
    delete( get(gcf,'Children'));
    
    subplot(311); 
    plot(t1, E(i,:), 'color', 'k');
    title(sprintf('%d', i));
    set(gca,'YLim', [-1000 500]);
    
    subplot(312);
    p(1) = patch([t2(1), t2, t2(end)], [0, H(i,:), 0],'r');
    set(gca,'YLim', [0 6000]);
    
    subplot(313);
    p(2) = patch([t2(1), t2, t2(end)], [0, C(i,:), 0],'b');
    set(gca,'YLim', [0 6000]);
    
    set( get(gcf,'Children'), 'XLim', win);
    pause;
    
end

ts = linspace(win(1), win(2), 751);

%%
close all;
f = figure('Position', [600 45 560 1070]);
ax = tight_subplot(15, 1,  [.01 0], .01, .025);
set(ax,'NextPlot', 'add')

exampleList = [3 11 20 22 24 37 47 50 72 76 80 87 89 117 124];
for i = 1:numel(ax)
    idx = exampleList(i);
    
    e = E(idx,:);
    h = H(idx,:);
    c = H(idx,:);
    
    e = (e + 1000) / 1500;
    h = h / 6000;
    c = c / 6000;
    
    
    
    patch( [t2(1), t2, t2(end)], [0, h, 0], 'r', 'Parent', ax(i));
    patch( [t2(1), t2, t2(end)], [0, c, 0], 'b', 'Parent', ax(i));
    line( t1, e, 'color', 'k','parent', ax(i));
end
    
    
    
    
%%
fn = sprintf('/data/HPC_RSC/EXAMPLES/rip_trig%i.svg', i);
plot2svg( fn, gcf);
%% Plot Raster Examples
ts = linspace(win(1), win(2), size(eegSamps{1},2) );
close all;
figure('Position', [460 30 650 1000]);

lims = [-.25 .5];
ax = []; labs = {}; tick = lims(1):.125:lims(2);

for i = 1:numel(tick)
    labs{i} = sprintf('%d', round(tick(i)*1000));
end

for iDay = 3:9
    H = MU(iDay).st_rCA1;
    H = H( ~cellfun(@isempty, H));
    C = MU(iDay).st_RSC;
    C = C( ~cellfun(@isempty, C));
    
    ax(1) = axes('Position', [.05 .80 .93 .19]);
    plot(HPC(iDay).ts, HPC(iDay).lfp, 'Parent', ax(1))
    
    ax(2) = axes('Position', [.05 .45 .93 .33]);
    rp = rasterplot(H, ax(2));
    set(ax(2),'YLim', [0, numel(H)]);
        
    
    ax(3) = axes('Position', [.05 .1 .93 .33]);
    rp = rasterplot(C, ax(3));
    set(ax(3),'YLim', [0, numel(C)]);

    linkaxes(ax,'x');
    nEvent = numel(eventTS{iDay});
    
    for iEvent = 1:nEvent
        set(ax, 'XLim', eventTS{iDay}(iEvent) + lims, 'XTick', []);
        set(ax(3), 'XTick', eventTS{iDay}(iEvent) + tick, 'XTickLabel', labs );
        pause;
    end
    
    delete ax;    
end


%%

figure;
subplot(311);
plot(t1, mean(E));

ax = subplot(312);
error_area_plot(t2, mean(H), std(H) * 1.96 ./ sqrt( size(H,1) ), 'Parent', ax)

ax = subplot(313);
error_area_plot(t2, mean(C), std(C) * 1.96 ./ sqrt( size(C,1) ), 'Parent', ax)

set(get(gcf,'children'),'XLim', win);


%%

rasterplot( MU(1).spike_times(5:end));
set(gca,'XLim', minmax(MU(1).ts));

%%


%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];

bId = [1 1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3, 3];

for i = 1 : 9
   process_dset( sprintf('gh-rsc%d',bId(i)),  day(i), sprintf('sleep%d', ep(i)) );  
   
end