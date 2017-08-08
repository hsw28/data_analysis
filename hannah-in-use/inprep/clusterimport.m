function f = clusterimport(array);
  %makes an structure of all the cluster times for easier manipulation
  %import a cell array of file paths names using uipickfiles

array = array';


for k=1:length(array)
  %imports path name as string and trunctates string so it's not so long
  name = char(array(k));
  name = strsplit(name,'Data/');
  name = (name(1,2));
  %replaces characters that cant be in structure names
  name = strrep(name, '/', '_');
  name = strrep(name, '-', '_');
  name = strcat('cluster_', name)
  name = char(name);
  %loads data
  x = load(char(array(k)));
  x = x(:,8);
  %assigns to structure
  myStruct.(name) = x;
end

f = myStruct;
