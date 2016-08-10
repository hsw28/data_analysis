function g = trode_group( tName, trode_groups )

isOk = cellfun(@(x) any(strcmp(x.trodes,tName)), trode_groups);
if(sum(isOk) == 0)
    g = 'none';
    return;
elseif(sum(isOk) > 1)
    error('trode_group:too_many',[tName, 'has Too many matches']);
else
    g = trode_groups{ cellfun(@(x) any(strcmp(x.trodes, tName)), trode_groups) };
end