function pos = load_linear_position(baseDir)  
    
    if ~ischar(baseDir) || ~exist(baseDir, 'dir')
        error('baseDir must be a string and valid directory');
    end
    
    ep = 'amprun';

    lin_pos_path = sprintf('%s/amprun.lin_pos.p', baseDir);
    f = mwlopen(lin_pos_path);

    l = load(f);    
    pos.ts = l.timestamp;
    pos.lp = l.lp;
    pos.lv = l.lv;
    pos.xp = l.xp;
    pos.yp = l.yp;
    
    
end