function first_phase_by_trode_pos( place_cells, eeg_r, pos_info, rat_conv_table, varargin )
% FIRST_PHASE_BY_TRODE_POS (place_cells, eeg_r, []) 
%  Make two plots of place cell starting phase vs. position of source
%  tetrode.  One for global theta; one for local theta.  In each case,
%  report the variance of these phases.  Are they more aligned to global
%  theta, local theta (,or model_local theta)?


p = inputParser();
p.addParamValue('theta_sources',{'global'},@(x) any(strcmp(x,{'global','local','model_local_full','model_local_for_missing'})));
p.addParamValue('model_eeg_r',[]);
p.addParamValue('model_params',[]);
p.addParamValue('global_chan_label', place_cells.clust{1}.comp);
p.addParamValue('draw',true);
p.addParamValue('dash_len',.2);
p.parse(varargin{:});
opt = p.Results;

n_sources = numel(opt.theta_sources);
if(opt.draw)
    f = figure;
    for n = 1:n_sources
        ax(n) = subplot(1,n_sources,n);
        title(opt.theta_sources{n});
    end
end

for a = 1:n_sources
    this_source = opt.theta_sources{n};
    if (strcmp(this_source,'global'))
        global_eeg_ind = find(strcmp(opt.global_chan_label, eeg_r.raw.chanlabels),1);
        this_place_cells = assign_theta_phase(place_cells,eeg_r,'local_phase',false,'lfp_default_chan', global_eeg_ind);
    elseif(any(strcmp(this_source,{'model_local_full','model_local_for_missing'})))
        if(isempty(opt.model_params))
            error('first_phase_by_trode_pos:no_model_params','When using model_local data, you must pass model params a-la gh_long_wave_regress');
        end
        if(strcmp(this_source,'model_local_full'))
            this_eeg_r = new_eeg_from_model(eeg_r, opt.model_params, rat_conv_table, 'place_cells', place_cells, 'overwrite_existing',true);
        elseif(strcmp(this_source,'model_local_for_missing'))
            this_eeg_r = new_eeg_from_model(eeg_r, opt.model_params, rat_conv_table, 'place_cells', place_cells, 'overwrite_existing',false);
        end
        this_place_cells = assign_theta_phase(place_cells,this_eeg_r, 'local_phase',true);
    elseif (strcmp(this_source,'local'))
        keep_bool = cellfun(@(x) any(strcmp(x.comp,eeg_r.raw.chanlabels)), place_cells.clust);
        this_place_cells = place_cells;
        this_place_cells.clust = this_place_cells.clust(keep_bool);
        this_place_cells = assign_theta_phase(this_place_cells,eeg_r, 'local_phase',true);
    end
    this_trodexy = mk_trodexy(place_cells,rat_conv_table);
    this_phase_starts_stops = cellfun(@(x) field_first_last_phase(x,pos_info), this_place_cells.clust,'UniformOutput',false);
    if(opt.draw)
        ax(a);
        draw_trodes(rat_conv_table);
        for n = 1:numel(this_phase_starts_stops)
            this_s = this_phase_starts_stops{n};
            for m = 1:size(this_s,2)
                this_orig = this_trodexy(n,:);
                this_tip = opt.dash_len .* [cos(this_s(1,m)), sin(this_s(1,m))] + this_orig;
                plot(ax(a),[this_orig(1),this_tip(1)],[this_orig(2),this_tip(2)],'-','Color',gh_colors(n));
                hold on;
            end
        end
    end
end