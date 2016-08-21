function list = dset_get_dset_file_list(epochList)
    if nargin==0
        epochList = {'run', 'sleep'};
    end
    
    if ~iscell(epochList)
        epochList = {epochList};
    end
    
    filenameTemplate = '/data/franklab/bilateral/dset/%s_%d_%d.mat';
    
    list = {};
    
    for iEpoch = 1:numel(epochList)

        epoch = epochList{iEpoch};
        eList = dset_list_epochs(epoch);
        
        for idxEpoch = 1:size(eList,1);
            [anim, dayN, epochN] = deal(eList{idxEpoch,:});
            if isempty( strfind(anim, 'spl') )
                list{end+1,1} = sprintf( filenameTemplate, anim, dayN, epochN );
            end
        end

    end
end