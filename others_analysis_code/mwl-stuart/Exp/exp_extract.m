function exp_extract(edir, varargin)
%
% see also exp_process
    args.tt_files = 1;
    args.pos_file =  1;
    args.eeg_files = 1;
    args.spike_parm = 1;
    args.binary_pxyabw = 1;
    args = parseArgs(varargin, args);     
    
    raw_dir = fullfile(edir, 'raw');
    if ~exist(raw_dir, 'dir')
        mkdir (fullfile(edir, 'raw'));
    end
    tt_f = nan;
    if args.tt_files
        tt_f = extract_tetrode_files(edir);
    end
    
    if args.pos_file
        extract_pos_file(edir);
    end
    
    if args.eeg_files
        extract_eeg_files(edir);
    end
    
    if args.spike_parm %&& args.tt_files && args.pos_file
        create_exp_pxyabw_files(edir, tt_f, args.binary_pxyabw);
    end
        
    file = fullfile(edir, 'meta.extracted');
    cmd = ['touch ', file];
    system(cmd);
end

function tt_f = extract_tetrode_files(edir)
    files = dir(fullfile(edir, 't*'));
    tt_f = {files.name};
    
    disp('Extracting Tetrodes');
    for f = tt_f
        file = f{1};
        if numel(file)>3
            
            t1 = [fullfile(edir, file(1:3), file(1:3)), '.tt'];
            t2 = [fullfile(edir, file(4:6), file(4:6)), '.tt'];
            ffile = fullfile(edir,  file);
            mkdir(fullfile(edir, file(1:3)));
            mkdir(fullfile(edir, file(4:6)));
        
        cmd =['/home/slayton/bin/mwsoft/adextract -eslen80 -t -probe 0 ', ffile, ' -o ', t1];
        system(cmd);
        cmd =['/home/slayton/bin/mwsoft/adextract -eslen80 -t -probe 1 ', ffile, ' -o ', t2];
        system(cmd);
             
            cmd = ['mv ', fullfile(edir, file), ' ', fullfile(edir, 'raw', file)];
            system(cmd);  
        end
    end
end

function extract_pos_file(edir)
    disp('Extracting Position Data');
    files = dir(fullfile(edir, 'master*'));
    pos_f = {files.name};
    if ~isempty(pos_f)
        file = pos_f{1};
        ffile = fullfile(edir, file);
    
        pos_file = fullfile(edir, [file(1:end-4), '.pos']);
        p_file   = fullfile(edir, 'position.p');
    
        cmd =['/home/slayton/bin/mwsoft/adextract -eslen80 ', ffile, ' -p -o ', pos_file];
        system(cmd);
    
        cmd =['/home/slayton/bin/mwsoft/posextract ', pos_file, ' -o ', p_file];
        system(cmd);
    
        cmd = ['mv ', ffile, ' ', fullfile(edir, 'raw', file)];
        system(cmd);
    end
    
end

function extract_eeg_files(edir)
    files = dir(fullfile(edir, 'eeg*'));
    eeg_f = {files.name};

    disp('Extracting EEG Data');
    for f = eeg_f
        file = f{1};
        ffile = fullfile(edir, file);
        eeg_file = fullfile(edir, [file(1:4), '_all.buf']);
        
        cmd =['/home/slayton/bin/mwsoft/adextract -eslen80 ', ffile, ' -c -o ', eeg_file];
        system(cmd);
     
        cmd = ['mv ', ffile, ' ', fullfile(edir, 'raw', file)];
        system(cmd);
    end

end



























