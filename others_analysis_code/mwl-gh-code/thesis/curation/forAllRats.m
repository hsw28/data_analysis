function res = forAllRats(fNames,fs,rats)

res = cell(size(fs));

for ratInd = 1:numel(rats)
    for fInd = 1:numel(ns)
        res.(fNames(fInd)) = [res.(fNames(fInd)),...
            fs{fInd}(rats{ratInd})];
    end
end

end