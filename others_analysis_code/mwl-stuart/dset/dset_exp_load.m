function dset = dset_exp_load(edir, epoch)

if strcmp(epoch, 'run')
    e = exp_load_run(edir, [1 7]);
    dset = exp2dset(e, epoch);

    switch edir
        case '/data/spl11/day11'
            dset.eeg = dset_exp_load_eeg(edir, 'run');
        case '/data/spl11/day12'
            dset.eeg = dset_exp_load_eeg(edir, 'run2');
    end
    
elseif strcmp(epoch, 'sleep')
    e = exp_load_sleep(edir, [1 7]);
    dset = exp2dset(e, epoch);

    
    switch edir
        
        case '/data/spl11/day11'
            dset.eeg = dset_exp_load_eeg(edir, 'sleep2');
        case '/data/spl11/day12'
            dset.eeg = dset_exp_load_eeg(edir, 'sleep3');
    end
    
end

  
dset.description.isexp = 1;
    
    
    