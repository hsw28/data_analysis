figure('Position', [125 135 1160 970]);
%%
%%  PLOT_TETRODE_SPIKES 
%%
xm = .075;
dx = .4;
ym = .075;
dy = .40;

plot_me1 = data.amps;
plot_me2 = data.cl;
%c = ['rgbcmyw'];
c = 'w';
%x = 1;
n = 2;

ax(1) = axes('Position', [xm + (dx+xm) * 0, ym + (dy+ym) * 1, dx, dy]);
ax(2) = axes('Position', [xm + (dx+xm) * 1, ym + (dy+ym) * 1, dx, dy]);
ax(3) = axes('Position', [xm + (dx+xm) * 0, ym + (dy+ym) * 0, dx, dy]);
ax(4) = axes('Position', [xm + (dx+xm) * 1, ym + (dy+ym) * 0, dx, dy]);
% 
% ax(4) = axes('Position', [xm, .025+ym*0, dx, dy]);
% ax(3) = axes('Position', [xm, .025+ym*1, dx, dy]);
% ax(2) = axes('Position', [xm, .025+ym*2, dx, dy]);e
% ax(1) = axes('Position', [xm, .025+ym*3, dx, dy]);

amp_n = 3;
p1 = 3;
p2 = 2;

xlims = [1 800];
ylims = [1 800];

   
nSpike = size(plot_me1{n},1);
%if nSpike>1e4
%    ind = randsample(nSpike,1e4);
%else
    ind = logical(1:nSpike);
%end
line(plot_me1{n}(ind,1), plot_me1{n}(ind,2), 'linestyle', '.','color', 'r', 'markersize', 5, 'Parent', ax(1)); 
line(plot_me1{n}(ind,2), plot_me1{n}(ind,3), 'linestyle', '.','color', 'r', 'markersize', 5, 'Parent', ax(2)); 
line(plot_me1{n}(ind,3), plot_me1{n}(ind,4), 'linestyle', '.','color', 'r', 'markersize', 5, 'Parent', ax(3)); 
line(plot_me1{n}(ind,1), plot_me1{n}(ind,3), 'linestyle', '.','color', 'r', 'markersize', 5, 'Parent', ax(4)); 

line(plot_me2{n}(:,1), plot_me2{n}(:,2), 'linestyle', '.','color', 'w', 'markersize', 1, 'Parent', ax(1)); 
line(plot_me2{n}(:,2), plot_me2{n}(:,3), 'linestyle', '.','color', 'w', 'markersize', 1, 'Parent', ax(2)); 
line(plot_me2{n}(:,3), plot_me2{n}(:,4), 'linestyle', '.','color', 'w', 'markersize', 1, 'Parent', ax(3)); 
line(plot_me2{n}(:,1), plot_me2{n}(:,3), 'linestyle', '.','color', 'w', 'markersize', 1, 'Parent', ax(4)); 

set(ax,'Xlim', xlims, 'YLim', ylims, 'color','k')

set(get(gcf,'Children'),'FontSize',16);
