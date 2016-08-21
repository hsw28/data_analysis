function tt_f = extract_tetrode_files(edir)
    files = dir(fullfile(edir, 't*'));
    tt_f = {files.name};
    
    disp('Extracting Tetrodes');
    for f = tt_f
        file = f{1};
        t1 = [fullfile(edir, file(1:3), file(1:3)), '.tt'];
        t2 = [fullfile(edir, file(4:6), file(4:6)), '.tt'];
        ffile = fullfile(edir,  file);
        mkdir(fullfile(edir, file(1:3)));
        mkdir(fullfile(edir, file(4:6)));
        
        cmd = ['adextract -eslen80 -t -probe 0 ', ffile, ' -o ', t1];
        system(cmd);
        cmd = ['adextract -eslen80 -t -probe 1 ', ffile, ' -o ', t2];
        system(cmd);
             
        cmd = ['mv ', fullfile(edir, file), ' ', fullfile(edir, 'raw', file)];
        system(cmd);  
    end
end