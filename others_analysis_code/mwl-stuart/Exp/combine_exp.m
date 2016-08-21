function exp = combine_exp(exp1, exp2)
exp = struct();
iscell(exp1.edir)
if iscell(exp1.edir)
    exp.edir = exp1.edir;
    exp.edir{end+1} = exp2.edir;
else
    exp.edir = {exp1.edir, exp2.edir};
end

if ~isempty(intersect(exp1.epochs, exp2.epochs))
    error('Cannot combine EXPs with similar epoch names');
end
exp.epochs = [exp1.epochs, exp2.epochs];

fn = fieldnames(exp1);
for i=1:numel(fn)
    f = fn{i};
    if strcmp('edir', f) || strcmp('epochs', f)
        continue;
    end
    exp.(f) = exp1.(f);
end

fn = fieldnames(exp2);
for i=1:numel(fn)
    f = fn{i};
    if strcmp('edir', f) || strcmp('epochs', f)
        continue;
    end
    exp.(f) = exp2.(f);
end

