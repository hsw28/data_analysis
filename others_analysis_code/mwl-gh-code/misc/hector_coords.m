midline_front_ap = -3.48; % set to desired TETRODE face a/p position
midline_front_ml = 2.8;  % set to desired TETRODE face m/l position
midline_back_ref_ap = -4.56; % reference back-end position a/p
midline_back_ref_ml = 3.75; % reference back-end position m/l
% front face position gets set in drive coords
% reference position is only used to calculate drive angle

trodes_length = 3; % set to the distance between front and back tetrodes
trodes_width = 0.5; % set to distance between tetrode rows
width_pad = 0.5; % set to measured sides-padding (ie dental acrylic added in short axis)
length_pad = 0.5; % set to front-back padding (ie dental added in long axis)

% Don't change any other parameters -
% the rest of the coordinates are derived

midline_slope = (midline_front_ap-midline_back_ref_ap)/(midline_front_ml - midline_back_ref_ml);

midline_rad = atan(midline_slope);
midline_slope_deg = atan(midline_slope)/pi * 180

names = {'leftup','leftdown','rightup','rightdown','leftmid','rightmid'};
% columns are points in arbitrary order
% row one is m/l position
% row two is a/p position
% these points are built around a horizontal tetrode array...
% (ie going from 0,0 to array_length,0)  and rotated later
% by the slope specified by the points above
coords = [-1*width_pad,-1*length_pad,trodes_length+length_pad,trodes_length+length_pad,0,trodes_length;...
   trodes_width/2+width_pad,-1*(trodes_width/2+width_pad),trodes_width/2+width_pad,-1*(trodes_width/2+width_pad),0,0];

rot_matrix=[cos(midline_rad), -sin(midline_rad); sin(midline_rad), cos(midline_rad)];
coords = rot_matrix*coords;

offset_ap = coords(2,5)-midline_front_ap;
offset_ml = coords(1,5)-midline_front_ml;

coords(1,:) = coords(1,:) - offset_ml;
coords(2,:) = coords(2,:) - offset_ap;

plot(coords(1,:),coords(2,:));
axis equal

display(['Point 1: (',num2str(coords(2,1),3),' a/p, ', num2str(coords(1,1),3),' m/l)']);
display(['Point 2: (',num2str(coords(2,2),3),' a/p, ', num2str(coords(1,2),3),' m/l)']);
display(['Point 3: (',num2str(coords(2,3),3),' a/p, ', num2str(coords(1,3),3),' m/l)']);
display(['Point 4: (',num2str(coords(2,4),3),' a/p, ', num2str(coords(1,4),3),' m/l)']);
display(['Array front: (',num2str(coords(2,5),3),' a/p, ',num2str(coords(1,5),3),' m/l)']);
display(['Array rear: (',num2str(coords(2,6),3),' a/p, ',num2str(coords(1,6),3),' m/l)']);
