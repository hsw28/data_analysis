function f = names2struct(namesCell, fullStruct)


for k = 1:length(namesCell)
  currentname = char(strrep(namesCell(k), '''', ''));

  newstruct.(currentname) = fullStruct.(currentname);
end

f = newstruct;
