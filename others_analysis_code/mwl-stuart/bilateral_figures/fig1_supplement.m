%% Mean Rip Trig LFP ALL DSETS
f = figure('Position', [216 91 1222 911]);
rips = ripples.sleep;
for i = 1:numel(rips)
    r = rips(i);
    subplot(4,5,i);
    plot(r.window, mean(r.raw{1}), r.window, mean(r.raw{3}));
    set(gca,'XLim',[-100 100]);
    set(gcf, 'Name', r.description);
    title([num2str(i), ' ', r.description]);
    disp([num2str(i), ' ', r.description]);   
end
set(gcf,'Name', 'SLEEP:Mean LFP');


save_bilat_figure('fig1-sup-a', f, 1);
%% Mean Rip Trig RIP ALL DSETS
f = figure('Position', [216 91 1222 911]);
for i = 1:numel(rips)
    r = rips(i);
    subplot(4,5,i);
    plot(r.window, mean(r.rip{1}), r.window, mean(r.rip{3}));
    set(gca,'XLim',[-100 100]);
    set(gcf, 'Name', r.description);
    title([num2str(i), ' ', r.description]);
    disp([num2str(i), ' ', r.description]);   
end
set(gcf,'Name', 'SLEEP:Mean Rip Band');
save_bilat_figure('fig1-sup-b', f,1);
%%
f = figure('Position', [216 91 1222 911]);
ax = [];
c = [];

for i = 1:numel(rips)
    r = rips(i);
    ax(i) = subplot(4,5,i);
    
    bins = 150:3:225;
    occ = hist3([r.peakFrM{1}, r.peakFrM{3}], {bins, bins});
    c(i) = corr2(r.peakFrM{1}, r.peakFrM{3});
    imagesc(bins, bins, occ, 'Parent', ax(i));
    title(sprintf('%d %s %3.3f', i, r.description, c(i)) );   
end
set(ax,'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
set(gcf,'Name', 'SLEEP:Bilateral Ripple Mean Freq Distribution');

save_bilat_figure('fig1-sup-c', f,1);
f = figure('Name', 'SLEEP'); hist(c); xlabel('Bilateral ripple freq corr'); title('Sleep');
save_bilat_figure('fig1-sup-d', f,1);


%%
