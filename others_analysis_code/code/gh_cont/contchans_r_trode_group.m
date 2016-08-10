function r = contchans_r_trode_group(eeg_r, trode_groups, groupName)

fNames = fields(eeg_r);

for n = 1:numel(fNames)
    r.(fNames{n}) = ...
        contchans_trode_group(eeg_r.(fNames{n}),trode_groups, groupName);
end