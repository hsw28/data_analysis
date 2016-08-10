function plot_rpos_and_fe_raster(r_pos, place_cells, pos_info, varargin)

p=inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('trode_groups', []);
p.addParamValue('split_plots', true);
p.addParamValue('color_by_group',true);
p.addParamValue('ok_directions',{'outbound','inbound'});
p.parse(varargin{:});
opt = p.Results;

if(opt.split_plots)
    ax(1) = subplot(2,1,1);
    plot_multi_r_pos(r_pos, pos_info, 'timewin', opt.timewin);
    ax(2) = subplot(2,1,2);
    field_extents_raster( place_cells, field_extents (place_cells, ...
         'rate_threshold', 10, 'run_direction', 'inbound', 'trode_groups', opt.trode_groups,...
        'extent_size_override', 0.1, 'max_fields', 1));
    linkaxes(ax,'x');
else
    plot_multi_r_pos(r_pos, pos_info, 'timewin', opt.timewin,'norm_c',true,'e',1.5);
    if(opt.color_by_group)
       for g = 1:numel(opt.trode_groups)
           keepCell = ...
               cellfun(@(x) any(strcmp(x.comp,opt.trode_groups{g}.trodes)), ...
               place_cells.clust);
           this_place_cells = place_cells;
           this_place_cells.clust = place_cells.clust(keepCell);
           field_extents_raster(this_place_cells,field_extents(this_place_cells,...
               'rate_threshold',5,'run_direction','outbound',...
               'trode_groups',opt.trode_groups,...
               'extent_size_override',0.1,'max_fields',1),...
               'Color',opt.trode_groups{g}.color);
       end
    else
        field_extents_raster( place_cells, field_extents (place_cells, ...
        'rate_threshold', 5, 'run_direction', 'outbound', ...
        'trode_groups', opt.trode_groups,...
        'extent_size_override', 0.1,'max_fields',1));
    
    end
end

end