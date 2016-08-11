function lookup_fun = lookup_t (row_labels,col_labels,data)
%
% r = LOOKUP_T (r_labels, c_labels, data_array)
% Associative lookup table
% 
%  row_labels, col_labels are lists of key strings
%  data cell array of values, 
%  
%  r is a lookup function.  Use as:  d = r( 'row_name', 'col_name' );

if( isempty(row_labels) || isempty(col_labels) )
    error('lookup_t:empty_input',['Some empty arguments.' ,...
        ' row_labels size: ', num2str(size(row_labels)), ...
        '.  col_labels size: ', num2str(size(col_labels))]);
end

if(~all(size(row_labels) == size(unique(row_labels))))
    error('lookup_t:nonunique_rows','Some row labels not unique.');
end
if(~all(size(col_labels) == size(unique(col_labels))))
    error('lookup_t:nonunique_cols','Some col labels not unique.');
end

lookup_fun = @(x,y) data{find(strcmp(x, row_labels),1, 'first'),find(strcmp(y, col_labels), 1,'first')};

%response = arrayfun( @x (data(