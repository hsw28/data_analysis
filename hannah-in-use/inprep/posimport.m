function f = posimport(array);
%import array of position files made using uipickfiles
%makes structures of position data, velocity, and acceleration

array = array';

for k=1:length(array)
  %imports path name as string and trunctates string so it's not so long
  name = char(array(k));
  name = strsplit(name,'Data/');
  name = (name(1,2));
  %replaces characters that cant be in structure names
  name = strrep(name, '/', '_');
  name = strrep(name, '-', '_');
  posname = strcat('position_', name)
  velname = strcat('vel_', name)
  accname = strcat('acc_', name)
  posname = char(posname);
  velname = char(velname);
  accname = char(accname);

  %loads data
  pos = load(char(array(k)));
  vel = velocity(pos);
  acc = accel(pos);
  %assigns pos structure
  myStruct.(posname) = pos;
  myStruct.(velname) = vel;
  myStruct.(accname) = acc;

end

f = myStruct;
