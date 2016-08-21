%% Setup Data Sets
clear edir;
edir{1} = '/data/greg/m/day02';

epoch = 'run';

for e = 1:numel(edir)
    exp = loadexp(edir{e},'epochs', epoch, 'data_types', 'pos');
    et = exp.(epoch).et;
    encoding_time = [et(1) mean(et)];
    
    velocity_filter_pxyabw_files(edir{e},epoch,'time_range', encoding_time);
end


