function velocity_filter_pxyabw_files(dirname, pos_info, epoch, varargin)

p = inputParser();
p.addParamValue('time_range',[-Inf Inf]);
p.addParamValue('vel_thold',[]);
p.addParamValue('pos_info',[]);
p.addParamValue('file_extension_to_add', 'filtered.pxyabw');
p.parse(varargin{:});
opt = p.Results;

args.time_range = [-Inf Inf];
args.vel_thold = .15;
args.file_extension = 'filtered.pxyabw';
args  = parseArgsLite(varargin,args);

projectNames = {'t_px', 't_py', 't_pa', 't_pb'};

eval(['cd ', dirname]);

%exp = loadexp(edir, 'epochs', epoch, 'data_types', {'pos'});

%vel = exp.(epoch).pos.lv;
%moving = abs(vel)>=abs(args.vel_thold);

allfiles = dir();
allfiles = allfiles(3:end); % drop the . and .. entries

%tt = load_exp_tt_list(edir);

outFields = {'id','t_px', 't_py', 't_pa', 't_pb','time'};
fieldType = {'int32', 'int16', 'int16', 'int16', 'int16', 'double'};
fieldSize = {1 1 1 1 1 1};

%outFields = {'id','t_px', 't_py', 't_pa', 't_pb','pos_x','pos_y','time'};
%fieldType = {'int32', 'int16', 'int16', 'int16', 'int16', 'int16', 'int16', 'double'};
%fieldSize = {1 1 1 1 1 1 1 1};

%for n = 1:numel(tt)
for n = 1:numel(allfiles)
%t = tt{n};
   if(~isempty(str2num(allfiles(n).name)))
       eval(['mkdir ', allfiles(n).name, '_velfilt']);
       eval(['cd ',allfiles(n).name]);
       
        in_file = [allfiles(n).name,'.pxyabw'];
        outfile= ['../',allfiles(n).name,'_velfilt/',allfiles(n).name,'.pxyabw'];
        %outfile = fullfile(edir,t,[t,'.',args.file_extension]);
        disp(['Creating ', outfile]);
        h = loadheader(in_file);
   
        if ~strcmp(h(2).('File type'), 'Binary')
            error('velocity_filter_parms_file:ascii_file','Need binary parms files.');
            %disp('Encountered non-Binary file, converting to Binary');
            %copy_pxyabw_file(in_file, in_file);
        end
    
    
        data = load(mwlopen(in_file));
        if isempty(data.id)
            warning('velocity_filter_pxyabw_files:no_id','in a funny no-id block');
            cmd = ['cp ', in_file, ' ', outfile];
            system(cmd);
            continue;
        end
    
        t_ind = data.time>=opt.time_range(1) & data.time<=opt.time_range(2);
        [tmp, v_ind] = gh_times_in_timewins(data.time, pos_info.run_bouts);
        %v_ind = interp1(exp.(epoch).pos.ts, moving, data.time);
        %v_ind(isnan(v_ind))=0;
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
    eval('cd ..');
        
   end             
end
    

