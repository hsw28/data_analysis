function f =  MASSposquadrants(array)

  %WILL LIKELY BE DEPRECATED

  
%input array of pos files using uipickfiles

array = array';

for k=1:length(array)
  %loads data
  pos = load(char(array(k)));
  vel = velocity(pos);
  acc = accel(pos);

  tme = pos(:,1);
  tme = tme';
  xpos = pos(:,2);
  xpos = xpos';
  ypos = pos(:,3);
  ypos = ypos';

  vel = vel(:,1)
  vel = vel';
  veltime = vel(:,2)
  veltime = veltime';

  acc = acc(:,1)
  acc = acc';
  acctime = acc(:,2)
  acctime = acctime';

% ASSIGN to vel and acc...

  %find INDEX of points in forced arms
  xforce = find(xpos<460);
  %assign these to points so now you have values instead of data
  timeforce = tme(xforce);
  xforce = xpos(xforce);
  yforce = ypos(xforce);


  %find INDEX of points in middle arm
  xmid = find(xpos>461 & xpos<850);
  ymid = find(ypos>300 & ypos<400);
  %find indices that appear in both
  bothindex = intersect(xmid, ymid);
  %assign these to points so now you have values instead of data
  timemiddle = tme(bothindex);
  xmiddle = xpos(bothindex);
  ymiddle = ypos(bothindex);

  %find INDEX of points in reward arm
  xreward = find(xpos>850);
  %assign these to points so now you have values instead of data
  timereward = tme(xreward);
  xreward = xpos(xreward);
  yreward = ypos(xreward);

  ////


  %imports path name as string and trunctates string so it's not so long
  name = char(array(k));
  name = strsplit(name,'Data/');
  name = char(name(1,2));
  name = strsplit(name,'/pos.csv');
  name = (name(1,1));
  %replaces characters that cant be in structure names
  name = strrep(name, '/', '_');
  name = strrep(name, '-', '_');
  name = strrep(name, ' ', '_');
  name = strcat('date_', name);
  posname = strcat(name, '_position');
  velname = strcat(name, '_vel');
  accname = strcat(name, '_acc');
  posname = char(posname);
  velname = char(velname);
  accname = char(accname);


  %assigns pos structure
  myStruct.(posname) = pos;
  myStruct.(velname) = vel;
  myStruct.(accname) = acc;


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';



end
