function create_cluster_test_dataset(edir, outdir, varargin)

args.sets = [4 3 2 1];
projectNames = {'t_px', 't_py', 't_pa', 't_pb'};
args.projections = [1 1 1 1; ...
                    1 1 1 0; ...
                    1 1 0 0; ...
                    1 0 0 0];
args.projections = ~logical(args.projections);
                
args.time_range = [-Inf Inf];
         
args = parseArgsLite(varargin, args);

tt = load_exp_tt_list(edir);

if ~exist(outdir,'dir');
    mkdir(outdir);
    disp(['Creating directory: ', outdir]);
end

for i=1:size(args.projections,2)
    d = [outdir,'.', num2str(5-i)];

    rm_fields = projectNames(args.projections(i,:));
    if ~exist(d,'dir')
        disp(['Creating directory: ', d]);
        mkdir(d);
    end
    for tNum = 1:numel(tt)
        tDir = fullfile(d, tt{tNum});
        if~exist(tDir,'dir')
            mkdir(tDir);    
        end
        
        infile = fullfile(edir, tt{tNum}, [tt{tNum}, '.pxyabw']);
        outfile = fullfile(tDir, [tt{tNum}, '.',num2str(5-i),'.pxyabw']);

        disp(['Creating: ', outfile]);
        copy_pxyabw_file(infile, outfile, 'rm_fields',rm_fields, 'time_range', args.time_range);

    end
        
end
    

