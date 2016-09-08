function sp = specto(data);

[s, f, t] = spectrogram(abs(data), 2000, 1000, 1000, 2000);
S = abs(s);

%imagesc(x,y,C) 

imagesc(t,f,S)
axis xy
colorbar
set(gca,'ylim',[0,300]);
set(gca,'clim',[0,3]);
