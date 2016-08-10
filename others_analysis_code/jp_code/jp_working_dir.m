function d = jp_working_dir(animal, day)

    if ~ischar(day)
        day = sprintf('%06d', day);
    end
    
    d = fullfile( jp_base_dir, animal, day);
    
    if ~exist(d,'dir')
        error('Invalid animal:day pair provided! %s does not exist', d);
    end
    
end