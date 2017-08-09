function f = timeimport(array);
  %outputs a structure LFP times for easier manipulation
  %input array of files using uipickfiles

array = array';

for k=1:length(array)
  %imports path name as string and trunctates string so it's not so long
  name = char(array(k));
  name = strsplit(name,'Data/');
  name = char(name(1,2));
  name = strsplit(name,'/arte_lfp');
  name = (name(1,1));
  %replaces characters that cant be in structure names
  name = strrep(name, '/', '_');
  name = strrep(name, '-', '_');
  name = strcat('date_', name);
  name = strcat(name, '_time');
  name = char(name);

  %loads data
  [lfp.timestamp, lfp.data] = gh_debuffer(char(array(k)), 'system', 'arte', 'gains', 5000, 'timewin', [0, inf]);
  myStruct(k).(name) = lfp.timestamp;

end

f = myStruct;
