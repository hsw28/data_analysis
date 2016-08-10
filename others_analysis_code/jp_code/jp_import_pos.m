function pos_info = jp_import_pos(edir)
    
    if ~exist(edir,'dir')
        warning('%s directory does not exist', edir);
        pos_info = [];
        return;
    end
    
    posFile = fullfile(edir, 'pos_info.mat');
    
    if ~exist(posFile,'file')
        warning('%s file does not exist', posFile);
        pos_info = [];
        return;
    end
    
    fprintf('Loading POS from:%s\n', edir);
    tmp = load(posFile);
    pos_info = tmp.pos_info;
    
end