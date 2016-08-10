function newM = filterMapKeys( fun, oldM )
% filter map elements acccording to predicate


newM = containers.Map;

keys = oldM.keys;

for n = 1:numel(keys)
    if( fun(keys{n}) )
        newM(keys{n}) = oldM(keys{n});
    end
end