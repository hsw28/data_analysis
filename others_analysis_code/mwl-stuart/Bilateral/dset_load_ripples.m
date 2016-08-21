function d = dset_load_ripples(epoch)

if nargin==0
    epoch = 'all';
end

epoch = lower(epoch);


if ~ any( strcmp( {'run', 'sleep', 'all'}, epoch ) )
    error('Invalid epoch type specified: %s', epoch)
end



file = sprintf('/data/franklab/bilateral/all_ripples.mat');
d = load(file);

if strcmp(epoch, 'all')
    d = d.data;
else
    d = d.data.(epoch);
end


bad_run = dset_get_bad_epochs('run');
bad_sleep = dset_get_bad_epochs('sleep');

[run_idx, sleep_idx] = deal( true(22,1) );

run_idx(bad_run) = false;
sleep_idx(bad_sleep) = false;


if numel(d.run) == 22
    d.run = d.run(run_idx);
end

if numel(d.sleep) == 22
    d.sleep = d.sleep(sleep_idx);
end