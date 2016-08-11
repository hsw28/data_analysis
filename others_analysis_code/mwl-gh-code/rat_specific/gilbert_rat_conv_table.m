function rat_conv_table = gilbert_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = { '21','23','25','27','26','29','28','02','30','03','04','05','06','08','07','01','12','13','14','11','15','10','16','17','09','18','19','20','22','24';...  
                                        21,             23,              25,               27,             26,            29,             28,              2,               30,             03,           04,        05,           06,               08,          07,            01,          12,       13,             14,           11,          15,          10,           16,             17,           9,           18,           19,             20,             22,       24 ;...
                                   -2.1953   -1.8651   -1.5217   -1.7463   -2.0632   -2.9085   -3.2387   -2.9877   -3.4368   -3.3179   -3.9254   -3.8330  -4.0047   -4.1368   -4.3085   -3.7802   -5.2198   -5.3782   -5.0745   -4.8896   -5.1801   -4.5066   -4.5330   -4.3613    -4.1896   -4.0443   -3.8858   -3.5688   -2.0236   -1.6802;...
                                    1.2783    1.2915    1.3047    1.6085    1.5689    2.0972    2.0576    2.6519    2.3217    2.6123    3.0745    3.3783    3.6953    3.3387    3.6028    2.2821    1.0802    0.8293    0.8161    1.0538    0.5387    1.1066    0.4859    0.7632    1.1331    0.7765    0.4991    0.5123    0.9878    1.0010;...
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