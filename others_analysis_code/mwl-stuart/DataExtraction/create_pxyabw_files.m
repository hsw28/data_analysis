function create_pxyabw_files(edir, tt_f)
    disp('Creating PXYABW Files');
    parms = 't_px,t_py,t_pa,t_pb,t_maxwd,t_maxht,time,t_h1,t_h2,t_h3,t_h4';
    %files = dir(fullfile(edir,'*.tt'));
    
    pos_file = fullfile(edir, 'position.p');
    %tt_f = {files.name};
    
    for f = tt_f
        file = f{1};
        t1 = [fullfile(edir, file(1:3), file(1:3)), '.tt'];
        t2 = [fullfile(edir, file(4:6), file(4:6)), '.tt'];
        
        px1_file = fullfile(edir, file(1:3), [file(1:3), '.pxyabw']);
        px2_file = fullfile(edir, file(4:6), [file(4:6), '.pxyabw']);
        
        cmd = ['/home/slayton/bin/mwsoft/spikeparms2 ', t1, ' -tetrode -parms ', parms, ' -pos ', pos_file, ' -o ', px1_file];
        system(cmd);
        cmd = ['/home/slayton/bin/mwsoft/spikeparms2 ', t2, ' -tetrode -parms ', parms, ' -pos ', pos_file, ' -o ', px2_file];
        system(cmd);
    end
    
end
