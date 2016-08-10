function units = jp_import_units(edir)
    
    if ~exist(edir,'dir')
        warning('%s directory does not exist', edir);
        units = [];
        return;
    end
    
    unitFile = fullfile(edir, 'units.mat');
    
    if ~exist(unitFile,'file')
        warning('%s file does not exist', unitFile);
        units = [];
        return;
    end
    
    fprintf('Loading Units from:%s\n', edir);
    tmp = load(unitFile);
    units = tmp.units;
    
end