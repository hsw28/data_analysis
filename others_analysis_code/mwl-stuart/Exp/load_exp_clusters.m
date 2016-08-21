function cl =  load_exp_clusters(edir, ep, varargin)
%LOAD_EXP_CELLS
%   loads cell data from disk, tetrodes can be ignored by using the
%   following keyvalue pair:
%   'ignore_tetrode', {'t01', 't02', 't##'}
%
%
    args.fields = {'time', 'id'};
    args.ignore_tetrode = {'none'};
    
    args = parseArgsLite(varargin, args);

    tt_dirs = load_exp_tt_list(edir);
%     st = {};
%     id = {};
%     loc = {};
%     file = {};
    nc = 0;
    cl = struct();
    
    for i = 1:numel(tt_dirs)
        t = tt_dirs{i};
        
        if ~ismember(args.ignore_tetrode, t)
            cl_files = get_dir_names(fullfile(edir, t, ep, 'cl*'));

            %disp(['Loading clusters from tetrode: ', t]);
            for j = 1:numel(cl_files)
                nc = nc + 1;

                c = cl_files{j};
                clf = fullfile(edir, t, ep, c);
                f = mwlopen(clf);
                data = load(f,args.fields);

                cl(nc).st = data.time;
                cl(nc).id = data.id;
                cl(nc).tt = t;
                cl(nc).loc = 'not defined';
                cl(nc).file = clf;
                

            end       
        else
            disp(['Skipping tetrode: ', t]);
        end
        
    end
    disp(['Loaded ', num2str(nc), ' units for: ', ep]);
    %cells = orderfields(cells);

end