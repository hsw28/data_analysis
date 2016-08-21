function e = exp_load_run(edir, operations)

dList = {'/data/spl11/day10', '/data/spl11/day11', '/data/spl11/day12', '/data/spl11/day13', '/data/spl11/day14' '/data/spl11/day15', '/data/spl11/day16'};
eList = {'run', 'run','run2','run','run','run', 'run'};

idx = find(strcmp(edir, dList));
if isempty(idx)
    error('Undefined edir');
end

e = exp_load(edir, 'epochs', eList(idx), 'data_types', {'pos', 'clusters'});

if nargin==1
    operations = [1 2 4 7];
elseif isempty( operations ) || ~isvector(operations) || ischar(operations) || iscell(operations)
    operations = [1 2 4 7];
end

e = process_loaded_exp2(e, operations);


if ~strcmp('run', eList{idx})
    e.run = e.(eList{idx});
    e = rmfield(e, eList{idx});
end


end