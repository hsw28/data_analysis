function update_epochs(day, name, time)

baseDir = sprintf('/data/gh-rsc2/day%d', day);


[n t] = load_epochs(baseDir)

if any(strcmp(n, name))
    fprintf('Epoch already exists\n');
%     return;
end;

n{end+1} = name;
t = [t; time];

save_epochs(baseDir, n(1:3), t(1:3,:));

end