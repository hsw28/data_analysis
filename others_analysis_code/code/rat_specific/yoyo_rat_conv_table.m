function rat_conv_table = yoyo_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'a1', 'a2', 'b1', 'b2', 'c1', 'c2', 'd1', 'd2', 'e1', 'e2', 'f1', 'f2', 'g1', 'g2', 'h1', 'h2', 'i1', 'i2';...
                         9,   10,   11,   12,   13,   15,   16,   17,    18,   19,   20,   21,    6,    5,    4,    3,    2,    1  ;...
                     -2.5835   -2.8882   -3.8416   -3.0062   -3.1929   -3.3600   -3.4386 -3.2715   -3.1143   -3.6647   -2.7998   -2.9177   -3.5467   -3.1536 -4.1856   -3.7630   -3.9300   -4.0873;...
                       2.9718    2.6573    3.7777    3.0406    3.4239    3.8268    3.0602 2.6966    2.2641    3.4042    1.5761    1.9005    2.3329    1.5663  3.7974    2.6966    3.0701    3.4042;...
                         0,    0,   0,   0,   0,   0,   0,    0,     0,    0,    0,   0,   0 ,    0,    0,    0,    0,    0;...
                         0,    0,    0,    0,    0,   0,   0,   0,    0,   0,   0,    0,    0,    0,    0,    0,    0,    0};

% inkscape_data = zeros(2,18);
% 
% for m = 3:4
%     for n = 1:8
%         inkscape_data(m-2,n) = rat_conv_table.data{m,n};
%     end
% end
% 
% isd_length = sqrt((max(inkscape_data(1,:))-min(inkscape_data(1,:))).^2+(max(inkscape_data(:,2)) - min(inkscape_data(:,2))).^2);
% real_length = 3; % THIS IS A GUESS
% 
% trode_pos = inkscape_data .*real_length ./ isd_length;
% 
% front_trode_ap = -3.25; % SO IS THIS
% front_trode_ml = 1.5; % AND AGAIN, HERE
% 
% front_trode_is_ap = 769;
% front_trode_is_ml = 521;
% back_trode_is_ap = 644;
% back_trode_is_ml = 648;
% 
% is_angle = angle((front_trode_is_ml - back_trode_is_ml) + i*(front_trode_is_ap - back_trode_is_ap));
% real_angle = 
% 
% trode_pos(2,:) = trode_pos(2,:) .* -1;
% 
% theta = -pi/2;
% r_mat = [cos(theta),-sin(theta);sin(theta),cos(theta)];
% 
% trode_pos = r_mat*trode_pos;
% 
% trode_pos(1,:) = trode_pos(1,:) - (trode_pos(1,9) - trode_7_ap);
% trode_pos(2,:) = trode_pos(2,:) - (trode_pos(2,9) - trode_7_ml);

%plot(trode_pos(2,:),trode_pos(1,:),'.')%

%for i = 1:18;
%    rat_conv_table.data{3,i} = trode_pos(1,i);
%    rat_conv_table.data{4,i} = trode_pos(2,i);
%end