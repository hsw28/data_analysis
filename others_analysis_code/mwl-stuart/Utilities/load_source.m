function [source location] = load_source(base_dir, sig)
%   source_id = LOAD_SOURCE(epoch_dir, signal_id) 
%   loads the source associated with SIGNAL_ID 
%
%   [source_id location] = LOAD_SOURCE(...) 
%   returns the String location allong with the source_id
%
%   base_dir is the base directory of an experiment
%   base_dir = '/home/user/data/animalID/experimentID'

    dataIN = load(fullfile(base_dir, 'sources.mat'));
    dataIN.sources;
    sig = repmat({sig}, length(dataIN.sources), 1);
    ind = find(cellfun(@strcmp, dataIN.sources(:,2), sig), 1, 'first');
    source = dataIN.sources{ind,1}(end-5:end);
    location = dataIN.sources{ind,3};
     