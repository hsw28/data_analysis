function copy_exp_epoch(edir, orig_epoch, new_epoch, varargin)
args.e_num = -1;
args.cp_cluster_files  = 0;
args = parseArgsLite(varargin, args);


    [en et]  = load_epochs(edir);

    
    if ~ismember(orig_epoch,en)
        error('Original epoch does not exist');
    elseif ismember(new_epoch, en)
        error('New epoch already exists');
    end
    
    ind = ismember(en, orig_epoch);
    
    new_times = et(ind,:);

    if args.e_num == -1;
        et = [et ; new_times];
        en(end+1) = {new_epoch};
    else
        et = [et(1:args.e_num-1,:); new_times; et(args.e_num:end,:)];
        en = [en(1:args.e_num-1), new_epoch, en(args.e_num:end)];
    end
    
    save_epochs(edir,en, et);
    
    if exist(fullfile(edir, new_epoch))
        error([fullfile(edir, new_epoch), ' already exists, it cannot be created']);
    end
    
    tt = dir(fullfile(edir,'t*'));
    tt_n = {tt.name};
    ind = logical(cell2mat({tt.isdir}));
    tt = tt_n(ind);
    for i=1:numel(tt)
        t = tt{i};
        if args.cp_cluster_files
            cmd = ['cp -r ', fullfile(edir, t, orig_epoch), ' ' fullfile(edir, t , new_epoch)];
            disp(['Copying: ', fullfile(edir, t, orig_epoch), ' ' fullfile(edir, t , new_epoch)]);
        else
            cmd = ['mkdir ', fullfile(edir, t, new_epoch)];
            disp(['Creating dir: ', fullfile(edir,t,new_epoch)]);
        end
        system(cmd);
    end

end