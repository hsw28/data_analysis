clear;
data.cl = dset_load_clusters('Bon', 4,2);
data.pos = dset_load_position('Bon',4,2);
%% DECODE RUN
%
%   -- Decode Run
%
%
lIdx = strcmp({data.cl.hemisphere}, 'left');
lRun = dset_reconstruct(data.cl(lIdx), 'time_win', [data.pos.ts(1) data.pos.ts(end)], 'tau', .25);
rRun = dset_reconstruct(data.cl(~lIdx), 'time_win', [data.pos.ts(1) data.pos.ts(end)], 'tau', .25);

noSpikesIdx = sum(lRun.spike_counts)==0 | sum(rRun.spike_counts)==0; 
%%
linvel = mean(abs(data.pos.smooth_vel),2);
estVel = interp1(data.pos.ts, linvel, lRun.tbins); 
isMovingIdx = estVel > 10;
%%
img = [];
img(:,:,1) = smoothn(lRun.pdf,'kernel', 'my_kernel', 'my_kernel', ones(3,1), 'normalize', 0);
img(:,:,3) = smoothn(rRun.pdf,'kernel', 'my_kernel', 'my_kernel', ones(3,1), 'normalize', 0);
img(:,:,2) = 0;%smoothn(rReplay.pdf,'kernel', 'my_kernel', 'my_kernel', ones(3,1), 'normalize', 0);

%%
corrVal = col_corr(img(:,:,1), img(:,:,3));
corrVal(noSpikesIdx) = nan;
%%
figure; 
ax = [];
ax(1) = subplot(211);
imagesc(img);
ax(2) = subplot(212);
plot(corrVal,'.');

linkaxes(ax, 'x');
%%
figure; 
plot(estVel, corrVal, '.');

%% 
figure;
bins = -.5:.05:1;

h1 = smoothn(histc(corrVal(isMovingIdx), bins),1, 'correct', 1);
h2 = smoothn(histc(corrVal(~isMovingIdx), bins),1, 'correct', 1);

h1 = h1 / sum(h1);
h2 = h2 / sum(h2);

plot(bins, [h1;h2]);

%% DECODE REPLAY
%
%   -- Decode Replay
%
%
lIdx = strcmp({data.cl.hemisphere}, 'left');
tau  = .03;

%data.replay = dset_reconstruct(data.cl, 'time_win', [data.pos.ts(1) data.pos.ts(end)], 'tau', .015);
    lReplay = dset_reconstruct(data.cl(lIdx), 'time_win', [data.pos.ts(1) data.pos.ts(1)+1000], 'tau', tau);
    rReplay = dset_reconstruct(data.cl(~lIdx), 'time_win', [data.pos.ts(1) data.pos.ts(1)+1000], 'tau', tau);

noSpikesIdx = sum(lReplay.spike_counts)==0 & sum(rReplay .spike_counts)==0; 

%%
linvel = mean(abs(data.pos.smooth_vel),2);
estVel = interp1(data.pos.ts, linvel, lReplay.tbins); 
isMovingIdx = estVel > 10;

%%
    img = smoothn(lReplay.pdf,'kernel', 'my_kernel', 'my_kernel', ones(6,1), 'normalize', 0);
    img(:,:,3) = smoothn(rReplay.pdf,'kernel', 'my_kernel', 'my_kernel', ones(6,1), 'normalize', 0);
    img(:,:,2) = 0;%smoothn(rReplay.pdf,'kernel', 'my_kernel', 'my_kernel', ones(3,1), 'normalize', 0);

%%
    corrVal = col_corr(img(:,:,1), img(:,:,3));
    corrVal (noSpikesIdx) = nan;
%corrVal(noSpikesIdx) = nan;
%%
figure; 
ax = [];
ax(1)= subplot(211);
imagesc(lReplay.tbins, lReplay.pbins, img); hold on;
plot(data.pos.ts, data.pos.linpos , 'w.'); 



ax(2) = subplot(212);


plot(lReplay.tbins(isMovingIdx), corrVal(isMovingIdx),'r.'); hold on;
plot(lReplay.tbins(~isMovingIdx), corrVal(~isMovingIdx),'bo');


plot(lReplay.tbins, isMovingIdx/2, 'g')

linkaxes(ax, 'x');

%% 
figure;
bins = -.5:.005:1;

h1 = smoothn(histc(corrVal(isMovingIdx), bins),3);
h2 = smoothn(histc(corrVal(~isMovingIdx), bins),3);

h1 = h1 / sum(h1);
h2 = h2 / sum(h2);

plot(bins, [h1;h2]);
%%
figure; 
plot(estVel, corrVal, '.');


