function d = dset_load_replay_recon(epoch)

if nargin==0
    epoch = 'all';
end

epoch = lower(epoch);


if ~ any( strcmp( {'run', 'sleep', 'all'}, epoch ) )
    error('Invalid epoch type specified: %s', epoch)
end


switch(epoch)
    case 'run'
        file = sprintf('/data/franklab/bilateral/all_recon_run.mat');
    case 'sleep'
        file = sprintf('/data/franklab/bilateral/all_recon_sleep.mat');
    case 'all'
        file = sprintf('/data/franklab/bilateral/all_recon.mat');
end
d = load(file);

end