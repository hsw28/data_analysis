function f = posimport(array);
%import array of position files made using uipickfiles
%makes structures of position data, velocity, and acceleration

array = array';

for k=1:length(array)
  %imports path name as string and trunctates string so it's not so long
  name = char(array(k));
  name = strsplit(name,'Data/');
  name = char(name(1,2));
  test = strsplit(name,'/box.csv')
  size(test)
  if size(test,2)>1
    name = strsplit(name,'/box.csv');
    name = (name(1,1))
  else
    name = strsplit(name,'/pos.csv');
    name = (name(1,1));
  end


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

  %loads data
  pos = load(char(array(k)));
  if length(pos)>0
    vel = velocity(pos);
    acc = accel(pos);
  else
    vel = 0;
    acc = 0;
  end
  %assigns pos structure
  myStruct.(posname) = pos;
  myStruct.(velname) = vel;
  myStruct.(accname) = acc;

end

f = myStruct;
