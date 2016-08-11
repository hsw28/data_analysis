function rat_conv_table = mrwolf_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'01', '02','03','04','05','06','07','08','09','10', '12','13','15','16','18','19','21','22','23','24','25','27','28','29' ;...
                                         1,              2,               3,                4,              5,             6,              7,               8,                9,             10,           12,           13,                15,            16,          18,             19,            21,          22,           23,             24,           25,           27,             28,             29 ;...
                                   -4.1684   -3.9198   -3.7755   -3.5028   -3.4226   -3.2863   -3.6471   -3.9278   -4.0882   -4.2646    -4.1203   -4.3769     -4.6416   -4.8180   -4.4330   -5.0826  -4.8581   -5.3633   -5.1628   -4.9784   -4.6736   -4.6656   -4.5453   -4.3769  ;...
                                    2.7943     2.5537     2.2169     1.9763     2.2009     2.4815     2.5377     2.7702     3.0830     3.2273      3.5321     3.9090       4.1175     4.4062     3.5160     4.4222    4.0774     4.3982     4.1817     3.8529     3.9651     3.5481     3.3637     3.0509    ;...
                                         1,2,3,4,5,6,7,8,9,10,12,13,15,16,18,19,21,22,23,24,25,27,28,29 ;...
                                         1,2,3,4,5,6,7,8,9,10,12,13,15,16,18,19,21,22,23,24,25,27,28,29};

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