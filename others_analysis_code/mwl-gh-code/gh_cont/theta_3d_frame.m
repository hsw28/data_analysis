function h = theta_3d_frame(fg, z_data,trodexy,ktime,z_lim)

cla(fg);

troderect = [min(trodexy(:,1)),min(trodexy(:,2));...
    max(trodexy(:,1)),max(trodexy(:,2))];

[xi yi] = meshgrid([troderect(1,1):0.1:troderect(2,1)],...
    [troderect(1,2):0.1:troderect(2,2)]);

x = trodexy(:,1);
y = trodexy(:,2);

%gd = griddata(x,y,double(z_data),xi,yi,'linear');
%mesh(xi,yi,gd);
h = plot3(x,y,double(z_data),'o');

%zlim([-0.3 0.3]);
zlim([-200 200])
xlim([0 5]);
ylim([-6 -1]);

%xlim([-10 10]);
%ylim([-10 15]);

title(num2str(ktime));