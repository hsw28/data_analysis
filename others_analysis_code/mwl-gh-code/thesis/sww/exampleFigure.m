function fig = exampleFigure(d,r,m)

%m = md.mdata;

%dPath=[md.mdata.basePath,'/d',num2str(md.twin(1)),'_',num2str(md.twin(2)),'.mat'];

%load(dPath,'d','r');

twin = [5250,5260];

rscRippleEnv = contwin(contchans_trode_group(r,d.trode_groups,'RSC'),twin);
ctxRippleEnv = contwin(contchans_trode_group(r,d.trode_groups,'CTX'),twin);

rscEeg = contwin(contchans_trode_group(d.eeg,d.trode_groups,'RSC'), twin);
ctxEeg = contwin(contchans_trode_group(d.eeg,d.trode_groups,'CTX'), twin);

[events,~] = find_dips_frames_by_lfp(rscRippleEnv,-0.004)

p.fpass = [2,20];
p.Fs = rscEeg.samplerate;
p.tapers = [3,5];
specWin = [0.3,0.005];
[rscS,t,f] = mtspecgramc( rscEeg.data, specWin, p);
[ctxS,t,f] = mtspecgramc( ctxEeg.data, specWin, p);

fig = figure(1);

ax(1) = subplot(5,1,1);
gh_plot_cont(contmap(@(x) smooth(mean(x,2) - mean(mean(x)),80), rscRippleEnv) );
ylim([-0.008,0.008]);

ax(2) = subplot(5,1,2);
imagesc( twin, [min(f),max(f)], mean(rscS,3)');
caxis([0,0.005]);
set(gca,'YDir','normal');

ax(3) = subplot(5,1,3);
gh_plot_cont(contmap(@(x) smooth(mean(x,2) - mean(mean(x)),80), ctxRippleEnv) );
ylim([-0.008,0.008]);

ax(4) = subplot(5,1,4);
imagesc( twin, [min(f),max(f)], mean(ctxS,3)');
caxis([0,0.005]);
set(gca,'YDir','normal');

ax(5) = subplot(5,1,5);
gh_draw_segs(events);
hold on;
centers = cellfun(@(x) mean(x),events);
plot(centers,ones(size(centers)),'.');

linkaxes(ax,'x');

xlim(twin);

a = 5;
