function badList = dset_get_bad_epochs(epochType)


if strcmp(epochType, 'run')
    badList = [ 8    11    19    21    22];
elseif strcmp(epochType, 'sleep')
    badList = [9 11 13 22];
end