function rat_conv_table = yolanda_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30';...  
                        100,    200,   300,   400,   500,   600,   700,   800,   900,  1000,  1100,  1200,  1300,  1400,  1500,  1600,  1700,  1800,  1900,  2000,  2100,  2200,  2300,  2400,  2500,  2600,  2700,  2800,  2900,   3000 ;...
                       -4.02, -3.81, -4.01, -4.20, -4.14, -4.36, -4.32, -4.58, -4.78, -5.26, -5.08, -5.54, -4.84, -5.25, -4.66, -5.08, -4.92, -4.51, -4.70, -4.47, -4.27, -4.34, -4.10, -3.90, -3.47, -3.70, -3.29, -3.88, -3.49, -3.63;...
                        3.39, 3.70,  4.04,  3.69,  4.39,  4.02,  4.69,  4.36,  4.68,  4.70,  4.33,  4.36, 4.02,  4.00,  3.68,  3.64,  3.31,  3.36,  2.98,  2.61,  3.01,  2.31,  2.70,  2.35,  2.40,  2.70,  2.73, 3.07, 3.07, 3.38;...
                         1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30 ;...
                         1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30};

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