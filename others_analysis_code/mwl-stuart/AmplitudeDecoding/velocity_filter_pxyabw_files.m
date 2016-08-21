function exp = velocity_filter_pxyabw_files(edir, epoch, varargin)

args.time_range = [-Inf Inf];
args.vel_thold = .15;
args.file_extension = 'filtered.pxyabw';

args  = parseArgsLite(varargin,args);
projectNames = {'t_px', 't_py', 't_pa', 't_pb'};
exp = loadexp(edir, 'epochs', epoch, 'data_types', {'pos'});

vel = exp.(epoch).pos.lv;
moving = abs(vel)>=abs(args.vel_thold);

tt = load_exp_tt_list(edir);

outFields = {'id','t_px', 't_py', 't_pa', 't_pb','time'};
fieldType = {'int32', 'int16', 'int16', 'int16', 'int16', 'double'};
fieldSize = {1 1 1 1 1 1};

for n = 1:numel(tt)
    t = tt{n};
   
    in_file = fullfile(edir,t,[t,'.pxyabw']);
    outfile = fullfile(edir,t,[t,'.',args.file_extension]);
    disp(['Creating ', outfile]);
    h = loadheader(in_file);
   
    if ~strcmp(h(2).('File type'), 'Binary')
        disp('Encountered non-Binary file, converting to Binary');
        copy_pxyabw_file(in_file, in_file);
    end
    
    
    data = load(mwlopen(in_file));
    if isempty(data.id)
        cmd = ['cp ', in_file, ' ', outfile];
        system(cmd);
        continue;
    end
    
    t_ind = data.time>=args.time_range(1) & data.time<=args.time_range(2);
    v_ind = interp1(exp.(epoch).pos.ts, moving, data.time);
    v_ind(isnan(v_ind))=0;
    ind = t_ind & v_ind;
    
    dataOut = struct();
    field_names = fieldnames(data);
    for fn=1:numel(field_names);
        f = field_names{fn};
        if ismember(f,outFields)
            dataOut.(f) = data.(f)(ind);
        end
    end
        
    mwlFields = mwlfield(outFields, fieldType, fieldSize);

    
    f = mwlcreate(outfile, 'feature', 'fields', mwlFields,...
        'FileFormat', 'binary', 'Mode', 'overwrite', ...
        'Data', dataOut);
    
end

                 
end
    

