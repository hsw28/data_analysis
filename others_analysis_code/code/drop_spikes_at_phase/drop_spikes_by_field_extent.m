function new_sdat = drop_spikes_by_field_extent(place_cells, pos_info, varargin)
% new_place_cells = DROP_SPIKES_BY_FIELD_EXTENT(place_cells,
%                                               ['edge_threshold',0.5])
% For each place cell, drop all the spikes      
% that fall in the second half of each
% place field. ('second' defind by running
% direction)

p=inputParser();
p.addParamValue('inclusion_threshold',5);
p.addParamValue('edge_threshold',1);
p.addParamValue('test_case_erase_half_of_track',false);
p.parse(varargin{:});
opt = p.Results;

n_units = numel(place_cells.clust);

fe_out = field_extents(place_cells,'rate_threshold',opt.edge_threshold,...
    'run_direction', 'outbound');
out_bouts = pos_info.out_run_bouts;
fe_in = field_extents(place_cells,'rate_threshold',opt.edge_threshold,...
    'run_direction', 'inbound');
in_bouts = pos_info.in_run_bouts;

for n = 1:n_units
    
    spikes = place_cells.clust{n}.stimes;
    pos_at_spikes = place_cells.clust{n}.data(:, ...
    find(strcmp('pos_at_spike', place_cells.clust{n}.featurenames),1,'first'));
    


    this_extents = fe_out(n).field_extents;    
    if(opt.test_case_erase_half_of_track)
       this_extents = [0 1.5];
    end
    [~,from_out_bouts] = gh_times_in_timewins(spikes, out_bouts);
    if(numel(this_extents > 0))
        field_drop_part = [mean(this_extents,2), this_extents(:,2)];
        [~,from_out_drop_part] = gh_times_in_timewins(pos_at_spikes, field_drop_part);
    elseif(numel(this_extents == 0))
        from_out_drop_part = zeros(size(from_out_bouts));
    end
        
    this_extents = fe_in(n).field_extents;
    if(opt.test_case_erase_half_of_track)
       this_extents = [0 1.5];
    end
    [~,from_in_bouts] = gh_times_in_timewins(spikes, in_bouts);
    if(numel(this_extents > 0))
        field_drop_part = [ this_extents(:,1), mean(this_extents,2)];
        [~,from_in_drop_part] = gh_times_in_timewins(pos_at_spikes, field_drop_part);
    elseif(numel(this_extents == 0))
           from_in_drop_part = zeros(size(from_in_bouts));     
    end
    drop_bool = or( and(from_out_bouts, from_out_drop_part),...
        and(from_in_bouts, from_in_drop_part) );
    
    s_times =  place_cells.clust{n}.data(:, strcmp(place_cells.clust{n}.featurenames, 'time'));
    place_cells.clust{n}.data = place_cells.clust{n}.data(~drop_bool, :);
    place_cells.clust{n}.stimes = reshape(s_times(~drop_bool), 1,[]);
    
end

new_sdat = place_cells;