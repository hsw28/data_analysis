function h = ripp_3d_frame(fg, lfp_data, env_data, rate_data,trodexy,ktime,z_lim)

cla(fg);

troderect = [min(trodexy(:,1)),min(trodexy(:,2));...
    max(trodexy(:,1)),max(trodexy(:,2))];

[xi yi] = meshgrid([troderect(1,1):0.1:troderect(2,1)],...
    [troderect(1,2):0.1:troderect(2,2)]);

x = trodexy(:,1);
y = trodexy(:,2);

%gd = griddata(x,y,double(z_data),xi,yi,'linear');
%mesh(xi,yi,gd);
h = plot3(x,y,double(lfp_data),'o');

%zlim([-0.3 0.3]);
zlim(z_lim)
xlim([-4 1]);
ylim([-2 2]);

%xlim([-10 10]);
%ylim([-10 15]);

title(num2str(ktime));