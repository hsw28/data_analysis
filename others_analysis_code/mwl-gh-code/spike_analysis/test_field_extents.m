function test_field_extents( place_cells, varargin )

p = inputParser();
p.addParamValue('inds_to_draw', 1:2);
p.addParamValue('rate_threshold', 5);
p.addParamValue('max_fields', 10 )
p.addParamValue('trode_group_list',[]);
p.addParamValue('run_direction', 'bidirect');
p.parse(varargin{:});
opt = p.Results;

fe = field_extents( place_cells, 'rate_threshold', opt.rate_threshold, ...
    'max_fields', opt.max_fields, 'trode_group_list', opt.trode_group_list,...
    'run_direction', opt.run_direction );

for n = opt.inds_to_draw
    figure;
    this_fields = place_cells.clust{n}.field;
    plot(this_fields.bin_centers, this_fields.out_rate, 'b');
    hold on;
    plot(this_fields.bin_centers, this_fields.in_rate, 'g');
    for m = 1:size(fe(n).field_extents)
        plot([fe(n).field_extents(m,1), fe(n).field_extents(m,1)],[0 10],'b','Color',fe(n).color);
        plot([fe(n).field_extents(m,2),fe(n).field_extents(m,2)],[0,10],'g','Color', fe(n).color);
    end
    title(fe(n).trode);
end