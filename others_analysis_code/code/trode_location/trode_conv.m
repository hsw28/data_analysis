function ans_val = trode_conv(index,from_st,to_st,rat_conv_table)

% rat_conv_table.label = {'comp';'drive';'brain_ap';'brain_ml'}
% rat_conv_table.data = 4xntrode cell array

from_row_index= find(strcmp(from_st,rat_conv_table.label));
to_row_index = find(strcmp(to_st,rat_conv_table.label));


from_col = find(strcmp(index,rat_conv_table.data(from_row_index,:)));

ans_val = rat_conv_table.data{to_row_index,from_col};