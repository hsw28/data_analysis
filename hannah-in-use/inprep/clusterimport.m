function f = clusterimport(myfolder)
  %put in parent folder. imports all the clusters in that folder and names them with the path

% store the data in a cell array

cd myfolder;
% number of files with cl in directory
foldersize = size(dir('../cl*'));
% puts the path in a vector
[pathstr,name,ext] = fileparts(dir('../cl*'));
% makes a matrix of file names
 names = (pathstr);

for k=1:foldersize
  name = char(names(k));
  myStruct.name = load(pathstr(k)));
  myStruct.name = myStruct.name(:,8);
end
