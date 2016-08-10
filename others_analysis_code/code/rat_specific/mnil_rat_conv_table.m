function rat_conv_table = mnil_rat_conv_table()

disp('Using an approximate mapping of tetrode to brain positions!!!');

rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml';'brain_st';'brain_dp'};
rat_conv_table.data = {'02', '01', '06', '03', '04', '05', '08', '09', '10', '07', '12', '11', '17', '18', '13', '16', '15', '14' ;...
                         9,   10,   11,   12,   13,   15,   16,   17,    18,   19,   20,   21,    6,    5,    4,    3,    2,    1 ;...
                     -2.9632   -2.9986   -4.7355   -3.4949   -4.0443   -4.5406   -3.6721   -3.1936   -4.3633   -3.8139   -2.7859   -3.2822   -3.7607   -3.2113   -5.2495 -4.7001   -4.0620   -4.9837;...
                       3.9076    2.5784    4.8825    4.0672    4.9356    4.4748    3.7127    3.4823    3.3759    4.4748    2.1707    2.9506    2.5784    1.9049    4.7584 3.8368    3.9254    4.3153;...
                         -2.1371    -1.4113    -3.2776    -2.3906    -3.0588    -3.0012    -2.2638    -1.9643    -2.3214    -2.7477    -1.1118    -1.7224    -1.6302    -1.1118    -3.3698, -2.7016    -2.5288    -3.0588 ;...
                         1.8567    0.5994   -0.1023    1.2135    0.9795    0.0439    0.5702    1.1257   -0.6287    1.0088    0.6579    0.5409   -0.4532   -0.3070   -0.8918, -0.8333    0.0731   -0.7164};

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