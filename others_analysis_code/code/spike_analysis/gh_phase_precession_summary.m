classdef gh_phase_precession_summary
    properties (SetAccess = public, GetAccess = public)
        sdat
        pos_info
        rat_conv_table
        field_summary
        opt
    end
    methods
        function obj = gh_phase_precession_summary(sdat_in,pos_info_in,rat_conv_table_in,varargin)
            
            p = inputParser();
            p.addParamValue('multi_field_per_cell',false,@islogical);
            p.addParamValue('draw_indiv_cells',true,@islogical);
            p.addParamValue('run_direction','outbound');
            p.addParamValue('field_rate_cutoff',2,@isreal);
            p.parse(varargin{:});
            obj.opt = p.Results;
            obj.sdat = sdat_in;
            obj.pos_info = pos_info_in;
            obj.rat_conv_table = rat_conv_table_in;
            obj = lfun_construct(obj);
            disp(num2str(obj.field_summary));
            disp(num2str(obj.info));
        end
        function h = plot_all_fields
            h = lfun_plot(obj);
        end
        function [col_names,trode_avgs] = get_trode_mean_phases(obj)
            [col_names,trode_avgs] =lfun_trode_mean_phases(obj);
        end
        function [col_names,cell_avgs] = get_cell_mean_phases(obj)
            [col_names, cell_avgs] = get_cell_mean_phases(obj);
        end
        function [col_names,field_avgs] = get_field_mean_phases(obj)
            [col_names, field_avgs] = get_field_mean_phases(obj);
        end
    end
end

function obj = lfun_construct(obj)

ap_ind = find(strcmp(obj.rat_conv_table.label,'brain_ap'));
ml_ind = find(strcmp(obj.rat_conv_table.label,'brain_ml'));
comp_ind = find(strcmp(obj.rat_conv_table.label,'comp'));

ntrode = size(obj.rat_conv_table.data,2);
ncell = numel(obj.sdat.clust);
obj.field_summary.ntrode = ntrode;
obj.field_summary.ncell = ncell;
comp_list = cell(0);
for m = 1:ntrode
    obj.field_summary.trode(m).comp = obj.rat_conv_table.data{comp_ind,m};
    obj.field_summary.trode(m).ncell = 0;
    %comp_list = {comp_list,obj.field_summary.trode(m).comp};
    comp_list{numel(comp_list)+1} = obj.field_summary.trode(m).comp;
end
for m = 1:ncell
    comp_list
    this_clust = obj.sdat.clust{m}
    comp_ind_for_this_cell =find(strcmp(this_clust.comp,comp_list))
    obj.field_summary.trode(comp_ind_for_this_cell) = ...
        lf_add_clust_to_trode(this_clust,obj.field_summary.trode(comp_ind_for_this_cell),obj.opt)
end
end % end function lfun_construct

function trode = lf_add_clust_to_trode(clust,trode,opt)
    %trode
    %trode.ncell
    trode.ncell = trode.ncell + 1;
    
    if(strcmp(opt.run_direction,'outbound'))
        field = clust.field.out_rate;
        forward_dir = 1; % a direction multiplier for stepping through field data
    elseif(strcmp(opt.run_direction,'inbound'))
        field = clust.field.in_rate;
        forward_dir = -1;
    else
        warning('Unknown run direction in gh_phase_precession_summary:lf_add_clust_to_trode');
    end
    
    field(field < opt.field_rate_cutoff) = 0;
    keep_going = 1;
    this_cell_data.n_field = 0;
    
    while(keep_going)
        [max_rate, max_ind] = max(field);
        if (max_rate > 0)
            max_ind = max_ind(1) % discard multiple max matches; other field peaks will be picked up on subsequent cycles
            figure;plot(field);title(num2str(max_ind));
            this_cell_data.n_field = this_cell_data.n_field+1;
            this_cell_data.field(this_cell_data.n_field).peak = clust.field.bin_centers(max_ind);
            cursor_ind = max_ind
            while(all([field(cursor_ind)>0,(cursor_ind >= 0),(cursor_ind <= numel(clust.field.bin_centers))])) % track in backward direction
                cursor_ind = cursor_ind - forward_dir;
            end
            start_ind = cursor_ind + forward_dir
            this_cell_data.field(this_cell_data.n_field).start = clust.field.bin_centers(start_ind);
            cursor_ind = max_ind;
            % field(cursor_ind) = 1; % re-establish a field rate here, so that the loop doesn't stop; it was zeroed while finding the field start
            while (all([field(cursor_ind)>0,(cursor_ind >= 0),(cursor_ind <= numel(clust.field.bin_centers))])) % now track forward
                cursor_ind = cursor_ind + forward_dir;
            end
            cursor_ind;
            end_ind = cursor_ind - forward_dir
            this_cell_data.field(this_cell_data.n_field).end = clust.field.bin_centers(end_ind);
            field( min([start_ind,end_ind]) : max([start_ind,end_ind]) ) = 0;
        else
            keep_going = 0;
        end
        if(not(opt.multi_field_per_cell))
            keep_going = 0;
        end
    end
    trode.clust(trode.ncell) = this_cell_data;
end

function h = lfun_plot(obj)
    disp('hi');
end

function [col_names, cell_avgs] = get_cell_mean_phases(obj)

col_names = 1;
cell_avgs = 2;
disp('hi1');

end

function [col_names, field_avgs] = get_field_mean_phases(obj)

col_names = 1;
field_avgs = 1;
disp('hi2');

end