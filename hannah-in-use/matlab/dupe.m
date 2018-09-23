function f = dupe(cluststruc, dupnum)

clustname = (fieldnames(cluststruc));
numclust = length(clustname);
for j=1:numclust
  name = char(clustname(j));
  cluststruc.(name) = repelem(cluststruc.(name), dupnum);
end

f = cluststruc;
