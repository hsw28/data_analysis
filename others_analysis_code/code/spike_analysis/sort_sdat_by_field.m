function new_sdat = sort_sdat_by_field(old_sdat,varargin)

p = inputParser();
p.addParamValue('field_direction','outbound');
p.parse(varargin{:});
opt = p.Results;

ps = old_sdat.clust{1}.field.bin_centers;
clusts_field_pos = cellfun(@(x) field_pos(x,ps,opt), old_sdat.clust);

[~,ord] = sort(clusts_field_pos);

new_sdat = old_sdat;
new_sdat.clust = old_sdat.clust(ord);


end

function p = field_pos(clust,ps,opt)

[max_out,i_out] = max(clust.field.out_rate);
[max_in,i_in] = max(clust.field.in_rate);
if(max_out > max_in)
    max_bi = max_out;
    i_bi = i_out;
else
    max_bi = max_in;
    i_bi = i_in;
end

if(strcmp(opt.field_direction,'outbound'))
p = ps(i_out);
elseif(strcmp(opt.field_direction,'inbound'))
p = ps(i_in);
elseif(strcmp(opt.field_direction,'biridect'))
p = ps(i_bi);
else
error('field_pos:bad_field_direct_arg','Bad field_direction arg');
end



end