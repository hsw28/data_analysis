function rat_conv_table = royale_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'a1', 'a2', 'b1', 'b2', 'c1', 'c2', 'd1', 'd2', 'e1', 'e2', 'f1', 'f2', 'g1', 'g2', 'h1', 'h2', 'i1', 'i2';...
                         9,   10,   11,   12,   13,   15,   16,   17,    18,   19,   20,   21,    6,    5,    4,    3,    2,    1  ;...
                     -3.25, -3.5, -3.8, -4.1, -4.3, -4.8, -4.6, -4.6,  -4.1,-3.75, -3.5, -4.9,-3.25, -3.5, -3.8, -4.1, -4.3, -4.6;...
                       2.3, 2.75,  3.2,  3.6,  4.0,  3.2, 2.75,  2.3,   1.9,  1.5,  1.0,  4.0, 1.5 ,  1.9,  2.3, 2.75,  3.2,  3.6;...
                         -6,    -8,   -10,   -12,   -14,   -12,   -10,    -8,     -6,    -4,    -2,   -15,    -3,    -5,    -7,   -9,   -11,   -13;...
                         3,    3,    3,    3,    3,   -3,   -3,   -3,    -3,   -3,   -3,    0,    0,    0,    0,    0,    0,    0};

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