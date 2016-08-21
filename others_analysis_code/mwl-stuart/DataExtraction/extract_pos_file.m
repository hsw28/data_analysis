function extract_pos_file(edir)
    disp('Extracting Position Data');
    files = dir(fullfile(edir, 'master*'));
    pos_f = {files.name};
    if ~isempty(pos_f)
        file = pos_f{1};
        ffile = fullfile(edir, file);
    
        pos_file = fullfile(edir, [file(1:end-4), '.pos']);
        p_file   = fullfile(edir, 'position.p');
    
        cmd = ['adextract -eslen80 ', ffile, ' -p -o ', pos_file];
        system(cmd);
    
        cmd = ['posextract ', pos_file, ' -o ', p_file];
        system(cmd);
    
        cmd = ['mv ', ffile, ' ', fullfile(edir, 'raw', file)];
        system(cmd);
    end
    
end