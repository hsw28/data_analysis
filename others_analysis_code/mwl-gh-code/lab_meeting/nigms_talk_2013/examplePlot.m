function f = examplePlot(eeg,mua)

f = figure('units','inches','position',[22 1 6 3],'menu','none');
%f = figure;

% Normal track run rsc and othercortex
timewin = 4650.5 + [0, 3.5];
%timewin = [3293, 3299];
dateStr = '112812';

% For sleep dep day
%timewin = [3167, 3173];
%dateStr = '032913';

%rscTrodes = {'11','21','22','17','16','18','19','15','13'};
%otherTrodes = {'28','05','25'};
%hpcTrodes = {'02','03','04','06','07','10','08'};

showRipples = false;

eeg = contwin(eeg,timewin);
eeg = contresamp(eeg,'resample',0.5);

eeg.data = -1 .* eeg.data;

plotEdges = linspace(0.0325,1-0.0325, 3);
plotHeight = plotEdges(2) - plotEdges(1);
plotWidth = 0.94;

i = 1;
ax(i) = axes('parent',f,'Position',[0.03,plotEdges(i),plotWidth,plotHeight],'Color',[1 1 1]);
gh_plot_cont(eeg,'trode_groups',caillou_trode_groups('date',dateStr),'timewin',timewin,'draw_chanlabels',false,'draw_y_ticks',false,'spacing',1,'LineWidth',1);
lfun_format_box();
ylim([-1,12]);

i = 2;
ax(i) = axes('parent',f,'Position',[0.03,plotEdges(i),plotWidth,plotHeight]);
sdat_raster(mua, 'trode_groups', caillou_trode_groups('date',dateStr),'timewin',timewin);
lfun_format_box();

%i = 4;
%ax(i) = axes('parent',f,'Position',[0.03,plotEdges(i),plotWidth,plotHeight]);
%gh_plot_cont(contchans(eeg,'chanlabels',hpcTrodes{1}),'trode_groups',blue_trode_groups('date',dateStr),'timewin',timewin,'draw_chanlabels',false,'draw_y_ticks',false,'spacing',1,'LineWidth',1);
%lfun_format_box();
%ylim([-1,1]);

%i = 3;
%ax(i) = axes('parent',f,'Position',[0.03,plotEdges(i),plotWidth,plotHeight]);
%sdat_raster(sdatslice(mua,'trodes',hpcTrodes), 'trode_groups', blue_trode_groups('date',dateStr),'timewin',timewin);
%lfun_format_box();

set(gcf,'Color',[0 0 0])
linkaxes(ax,'x');
xlim(timewin);

set(gcf,'Position',[22 1 5.5 6]);

end

function lfun_format_box()
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'XColor',[0 0 0]);
set(gca,'YColor',[0 0 0]);
set(gca,'Box','off');
set(gca,'LineWidth',10);
set(gca,'Color',[0 0 0]);
xlabel('');
ylabel('');
end