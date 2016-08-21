function [s] = dset_get_description_string(d)
    if ~isfield(d, 'description')
        error('No description data to work with');
    end
    
    if ischar(d.description.day)
        s = sprintf('%s %s:%s', d.description.animal, d.description.day, d.description.epoch);
    else
        s = sprintf('%s %d:%d', d.description.animal, d.description.day, d.description.epoch);
    end
    

end