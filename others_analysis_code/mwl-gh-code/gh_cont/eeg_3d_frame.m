function h = theta_3d_frame(fg, z_data,trode_xy,ktime,z_lim)

cla(fg);

troderect = [min(trode_xy(:,2)),min(trode_xy(:,1));...
    max(trode_xy(:,2)),max(trode_xy(:,1))];

[xi yi] = meshgrid([troderect(1,1):0.1:troderect(2,1)],...
    [troderect(1,2):0.1:troderect(2,2)]);

x = trode_xy(:,1);
y = trode_xy(:,2);

%gd = griddata(x,y,double(z_data),xi,yi,'linear');
%mesh(xi,yi,gd);
h = plot3(x,y,double(z_data),'o');

%zlim([-0.5 0.5]);
zlim([-0.4 0.4])
xlim([1 5]);
ylim([-6 -2]);

%xlim([-10 10]);
%ylim([-10 10]);

%xlim([-10 10]);
%ylim([-10 15]);

title(num2str(ktime));