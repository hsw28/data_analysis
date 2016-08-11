function st_fieldsize = staxis_fieldsize_array(sdat, rat_conv_table, varargin)

p = inputParser();
p.addParamValue('field_rate_thresh',2);
p.addParamValue('field_rate_thresh_units','Hz');
p.parse(varargin{:});
opt = p.Results;

comp_ind  = strcmp(rat_conv_table.label,'comp');
ap_ind = strcmp(rat_conv_table.label,'brain_ap');
ml_ind = strcmp(rat_conv_table.label,'brain_ml');

comp_list = rat_conv_table.data(comp_ind,:);
ap_list = rat_conv_table.data(ap_ind,:);
ml_list = rat_conv_table.data(ml_ind,:);

n_trodes = size(rat_conv_table.data,2);

st_fieldsize = struct('comp',{},'ap',{},'ml',{},'fields',{});

for n = 1:n_trodes
    st_fieldsize(n).comp = comp_list{n};
    st_fieldsize(n).ap = ap_list{n};
    st_fieldsize(n).ml = ml_list{n};
end

for n = 1:length(sdat.clust)
    this_cl = sdat.clust{n};
    st_array_ind = strcmp(this_cl.comp, comp_list);
    
    this_field = this_cl.field;
    if(max(this_field.out_rate) > max(this_field.in_rate))
        ratemap = this_field.out_rate;
    else
        ratemap = this_field.in_rate;
    end
    ratemap = [0, ratemap, 0];
    d_bin = this_field.bin_centers(2) - this_field.bin_centers(1);
    bin_centers = [ min(this_field.bin_centers)-d_bin, this_field.bin_centers, max(this_field.bin_centers) + d_bin];
    [m,i] = max(ratemap);
    start_ind = bin_centers(find(diff(ratemap > opt.field_rate_thresh) ==  1) + 1);
    end_ind   = bin_centers(find(diff(ratemap > opt.field_rate_thresh) == -1) + 1);
    range_bool = logical(bin_centers(i) >= start_ind) & logical(bin_centers(i) <= end_ind);
    field_range = [(start_ind(range_bool)), (end_ind(range_bool))];
    
    st_fieldsize(st_array_ind).fields = [st_fieldsize(st_array_ind).fields; field_range];
    %st_fieldsize(st_array_ind).fields = [ st_fieldsize(st_array_ind).fields;      0, sum([ this_field.out_rate >= opt.field_rate_thresh, this_field.in_rate >= opt.field_rate_thresh])*(bin_centers(2)-bin_centers(1))];
    %st_fieldsize(st_array_ind).fields = [ st_fieldsize(st_array_ind).fields;      0, sum([ diff(this_field.out_rate > opt.field_rate_thresh) == 1, diff(this_field.in_rate > opt.field_rate_thresh) == 1])];
end