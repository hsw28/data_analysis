t = -30:.1:30;
y = sin(t);

h = hilbert(y);
idx = t>-2*pi & t<2*pi;

env = abs(h);
ang = angle(h);

close; figure('Position',[319   252   963   767]);
plot(t(idx),y(idx),'.'); hold on;

plot(t(idx),env(idx),'r.');
plot(t(idx),ang(idx),'g.');


set(gca, 'XTick', -pi:pi/4:pi,'YTick', -pi:pi/4:pi, 'XLim', [-pi pi], 'YLim', [-pi pi]);
grid on;
