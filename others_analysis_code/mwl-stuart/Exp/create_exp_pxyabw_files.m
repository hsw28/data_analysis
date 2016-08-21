
function create_exp_pxyabw_files(edir,  varargin)
    args.binary = 1;
    args = parseArgsLite(varargin,args);
    disp('Creating PXYABW Files');
    parms = 't_px,t_py,t_pa,t_pb,t_maxwd,t_maxht,time,t_h1,t_h2,t_h3,t_h4';
    %files = dir(fullfile(edir,'*.tt'));
    
    pos_file = fullfile(edir, 'position.p');
    %tt_f = {files.name};
    
    
    if logical(args.binary)
        bin = '-binary ';
    else
        bin = '';
    end
    
    tt_f = dir(fullfile(edir,'t*'));
    isdir = {tt_f.isdir};
    tt_f = tt_f(cell2mat(isdir));
    valid = logical(1:numel(tt_f));
    tt_f = {tt_f.name};
    for i=1:numel(tt_f)
        
        if ~exist(fullfile(edir, tt_f{i}, [tt_f{i},'.tt']))
            valid(i) = 0;
        end
    end
    
    for f = tt_f
        file = f{1};
        tt = [fullfile(edir, file, file), '.tt'];
        
        px_file = fullfile(edir, file, [file, '.pxyabw']);

        
        cmd = ['/home/slayton/bin/mwsoft/spikeparms2 ',bin, tt, ' -tetrode -parms ', parms, ' -pos ', pos_file, ' -o ', px_file];
        disp(cmd);
        system(cmd);
        
    end
    
end