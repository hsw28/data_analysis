function sp = specto(data, minfreq, maxfreq, colorlimit);

% enter data, frequency min, frequency max, color bar limit
% ex: specto(hpc.data, 0, 300, 12)

[s, f, t] = spectrogram(abs(data), chebwin(2000, 60), 1000, 4000, 2000);

S = abs(s);

%imagesc(x,y,C) 

figure
imagesc(t,f,S)
axis xy
colorbar
set(gca,'ylim',[minfreq,maxfreq]);
set(gca,'clim',[0,colorlimit]);
