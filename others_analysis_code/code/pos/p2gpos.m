function gpos = p2gpos(p,opt)

np = numel(p.timestamp);
ngpos = numel(unique(p.timestamp));
uts = unique(p.timestamp);
[c, ind] = histc(p.timestamp,uts);
gpos.timestamp = uts;

%if(strcmp(p.frame0,'front'))
%    front_ind = find(p.frame == 0);
%    back_ind = find(p.frame == 1);
%else
%    front_ind = find(p.frame == 1);
%    back_ind = find(p.frame == 0);
%end

% collect frame0's, frame1's
f0.timestamp = p.timestamp(p.frame==0);
f0.x = p.x(p.frame == 0);
f0.y = p.y(p.frame == 0);
f1.timestamp = p.timestamp(p.frame==1);
f1.x = p.x(p.frame==1);
f1.y = p.y(p.frame==1);

[f0cnt, f0_ind] = histc(f0.timestamp,uts);
[f1cnt, f1_ind] = histc(f1.timestamp,uts);

gpos.timestamp(f0_ind) = f0.timestamp;
gpos.front_x(f0_ind) = f0.x;
gpos.front_y(f0_ind) = f0.y;
gpos.back_x(f1_ind) = f1.x;
gpos.back_y(f1_ind) = f1.y;

bad_ind = unique([find(gpos.front_x == 0),find(gpos.front_y == 0),...
    find(gpos.back_x == 0),find(gpos.back_y == 0)]);

good_ind = setdiff([1:ngpos],bad_ind);

gpos.timestamp = gpos.timestamp(good_ind);
gpos.front_x = gpos.front_x(good_ind)';
gpos.front_y = gpos.front_y(good_ind)';
gpos.back_x = gpos.back_x(good_ind)';
gpos.back_y = gpos.back_y(good_ind)';

gpos.info = p.info;

return