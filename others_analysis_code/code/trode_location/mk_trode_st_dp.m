function trodexy = mk_trode_st_dp(cdat,conv_table)

nchans = size(cdat.data,2);

trodexy = NaN.*zeros(nchans,2);

comp_ind = find(strcmp(conv_table.label,'comp'));
x_ind = find(strcmp(conv_table.label,'brain_st'));
y_ind = find(strcmp(conv_table.label,'brain_dp'));

for i = 1:nchans
    this_comp = find(strcmp(conv_table.data(comp_ind,:),cdat.chanlabels{i}));
    for j = [1,2]
        if(j == 1)
            this_row_ind = x_ind;
        elseif (j == 2)
            this_row_ind = y_ind;
        end
        this_row_ind
        this_comp
        trodexy(i,j) = conv_table.data{this_row_ind,this_comp};
    end
end