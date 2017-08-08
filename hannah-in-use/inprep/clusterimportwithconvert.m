function f = clusterimportwithconvert(lfp);
  %makes an structure of all the cluster times for easier manipulation
  %converts bad timestamps if needed (input lfp or lfptimestamps) and also saves conversion factor for if you need it later
  %at the start of function you pick your clusters using uipickfiles


array = uipickfiles;
array = array';

%finds conversion factor
actualseconds = length(lfp) / 2000;
fakeseconds = lfp(end)-lfp(1);
conversionfactor = actualseconds/fakeseconds;
myStruct.conversion_factor = conversionfactor;


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
  x = x(:,8).*conversionfactor;
  %assigns to structure
  myStruct.(name) = x;
end


f = myStruct;
