function rat_conv_table = mnil_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','R1','R2','R13' ;...
                         3, 4,  5,  6,  7,  8,  9, 10, 11,  12,  14,  15,  16,  17,  18,  19,  20,  21,  1,   2,   13;...
-3.2353   -3.6118   -4.0353   -4.3059   -4.7059   -5.3529   -5.0706   -5.7647   -4.4118   -5.3882   -5.0824   -5.4588   -4.6824   -4.3059   -3.9647   -3.8941   -3.6118   -3.2588   -2.5765, -2.9412   -4.6824;... 
                       3.1412    3.6353    4.0353    4.5882    5.0353    4.9176    4.3176    4.2235    3.3412    3.6235    3.1059    2.3647    2.6588    2.2353    2.9529    1.7647    2.4588    1.9529    2.1059, 2.6235    3.9647;...
                         -3.2353   -3.6118   -4.0353   -4.3059   -4.7059   -5.3529   -5.0706   -5.7647   -4.4118   -5.3882   -5.0824   -5.4588   -4.6824   -4.3059   -3.9647   -3.8941   -3.6118   -3.2588   -2.5765, -2.9412   -4.6824;... 
                       3.1412    3.6353    4.0353    4.5882    5.0353    4.9176    4.3176    4.2235    3.3412    3.6235    3.1059    2.3647    2.6588    2.2353    2.9529    1.7647    2.4588    1.9529    2.1059, 2.6235    3.9647};

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