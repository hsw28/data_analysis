function new_cdat = gh_zero_bouts(cdat,bouts)
% gh_zero_bouts sets data in cdat to zero for all times in bouts 'bouts',
% or for all bouts in each cell of bouts_cell 'bouts'
% all bouts lists should be size 2 x n_bouts

if(iscell(bouts))
    bouts_cell = bouts;
else
    bouts_cell{1} = bouts;
end

ts = conttimestamp(cdat);

num_cell = numel(bouts_cell);

for i = 1:num_cell
    this_bouts = bouts_cell{i};
    num_bouts = size(this_bouts,2);
    for j = 1:num_bouts
        this_ind = ((ts >= this_bouts(1,j))&(ts <= this_bouts(2,j)));
        cdat.data(this_ind,:) = 0;
    end
end

for i = 1:size(cdat.data,2)
    cdat.datarange(i,:) = [min(cdat.data(:,i)), max(cdat.data(:,i))];
end

new_cdat = cdat;