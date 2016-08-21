function s = exp_load_sleep(edir, operations)

if nargin==1
    operations = [1 2 4 7];
elseif isempty( operations ) || ~isvector(operations) || ischar(operations) || iscell(operations)
    operations = [1 2 4 7];
end

dList = {'/data/spl11/day11', '/data/spl11/day12', '/data/spl11/day15'};
eList = {'sleep2', 'sleep3', 'sleep2'};

idx = find( strcmp(edir, dList) );

if isempty(idx)
    error('Sleep data for %s has not been clustered', edir);
end

s = exp_load(edir, 'epochs', eList{idx}, 'data_types', {'clusters'});

if any( operations == 1 )
   
    r = exp_load_run(edir, 1);

    clRun = r.run.cl;
    clSleep = s.(eList{idx}).cl;

    if numel(clRun) ~= numel(clSleep)
        warning('Epochs Run and Sleep have a different number of clusters, TC not loaded');
    else

        for i = 1:numel(clSleep)
            clSleep(i).tc1 = clRun(i).tc1;
            clSleep(i).tc2 = clRun(i).tc2;
            clSleep(i).tc_bw = clRun(i).tc_bw;
        end
        s.(eList{idx}).cl = clSleep;

    end
    
    operations = operations(operations ~= 1);
    
end

s = process_loaded_exp2(s, operations);


if ~strcmp(eList{idx}, 'sleep')
    s.sleep = s.(eList{idx});
    s = rmfield(s, eList{idx});
end