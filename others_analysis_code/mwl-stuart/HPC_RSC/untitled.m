


t = -40:.05:40;

x = sin(t);
y = sin(t-1);

%%
idx = find( t>10 & t <15 );

nLag = 80;
[c, l] = xcorr_win(y,x,idx, nLag, 'coeff');

figure;

subplot(311);
plot(t,x, 'r', t,y, 'k'); 
set(gca,'XLim', [5, 15]);
legend('x', 'x-1');

subplot(312);
plot(l,c);
% set(gca,'YLim', [-1 1]);

subplot(313);
[c, l] = xcorr(x,y,nLag, 'coeff');
plot( l,c);
