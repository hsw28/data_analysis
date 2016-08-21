%%
clc;
figure;

c = clusters2;
m = mua2;

a1 = axes('OuterPosition', [0 .22 1 .805]);
a2 = axes('OuterPosition', [0 -.01 1 .34]);
srb = spike_raster_browser(c,  a1);
cmap = [.9 .9 .9; 0 0 .3; ];
srb.color_map = cmap;
mub = multi_unit_browser(m,  a2);
mub.color = [ 0 0 .3];
set(a2, 'Color', cmap(1,:));
set(a1, 'XAxisLocation', 'top');
linkaxes([a1 a2],'x');

