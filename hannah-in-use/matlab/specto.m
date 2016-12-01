function sp = specto(data, minfreq, maxfreq, colorlimit);

% enter data, frequency min, frequency max, color bar limit
% ex: specto(hpc.data, 0, 300, 12)

[s, f, t] = spectrogram(abs(data), 2000, 1000, 1000, 2000);

S = abs(s);

%imagesc(x,y,C) 

figure
imagesc(t,f,S)
axis xy
colorbar
set(gca,'ylim',[minfreq,maxfreq]);
set(gca,'clim',[0,colorlimit]);
