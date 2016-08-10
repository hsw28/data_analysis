function dists_mat = get_anatomical_dists(place_cells, field_cells, rat_conv_table, varargin)


p = inputParser();
p.addParamValue('axis_vector', [1 -1]./sqrt(2) );
p.parse(varargin{:});
opt = p.Results;

trode_xy = mk_trodexy(place_cells, rat_conv_table);
n_cells = size(trode_xy,1);
proj_list = cellfun( @(x) lfun_proj(x, opt.axis_vector), ...
    mat2cell(trode_xy, ones(n_cells, 1), 2));

dist_array = repmat( reshape(proj_list,[],1), 1, n_cells);

dists_mat = dist_array - (dist_array');

end

function d = lfun_my_abs(v)
    d = sqrt(sum(v.^2));
end


function p = lfun_proj(a, b)
    p = dot(a,b)./lfun_my_abs(b);
end