function rat_conv_table = skeeter_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml'}
rat_conv_table.data = {'g1','h2','i1','i2','h1','f1','f2','e1','d2','d1','e2','g2','a2','a1','b2','c1','c2','b1';...
    20, 21, 1,  2,  3,  4,  5,  6,  7  ,8,  9,  19, 18, 17, 14, 13, 12, 10;...
    
    381,361,358,434,498,555,620,678,741,663,590,293,453,577,643,457,494,558;...
    914,796,867,728,671,611,550,492,541,587,640,927,849,728,663,774,734,678};

inkscape_data = zeros(2,18);

for m = 3:4
    for n = 1:18
        inkscape_data(m-2,n) = rat_conv_table.data{m,n};
    end
end

isd_length = sqrt((741-293).^2+(541-927).^2);
real_length = 3.5; % THIS IS A GUESS

trode_pos = inkscape_data .*real_length ./ isd_length;

trode_7_ap = -3; % SO IS THIS
trode_7_ml = 1.3; % AND AGAIN, HERE

trode_pos(2,:) = trode_pos(2,:) .* -1;

theta = -pi/2;
r_mat = [cos(theta),-sin(theta);sin(theta),cos(theta)];

trode_pos = r_mat*trode_pos;

trode_pos(1,:) = trode_pos(1,:) - (trode_pos(1,9) - trode_7_ap);
trode_pos(2,:) = trode_pos(2,:) - (trode_pos(2,9) - trode_7_ml);

plot(trode_pos(2,:),trode_pos(1,:),'.')

for i = 1:18;
    rat_conv_table.data{3,i} = trode_pos(1,i);
    rat_conv_table.data{4,i} = trode_pos(2,i);
end