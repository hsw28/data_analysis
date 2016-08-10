function st_fieldsize = staxis_phase_precession_array(sdat, pos_info, rat_conv_table, varargin)

p = inputParser();
p.addParamValue('field_rate_thresh',2);
p.addParamValue('field_peak_thresh',10);
p.addParamValue('field_rate_thresh_units','Hz');
p.addParamValue('edge_limits',[]);
p.addParamValue('field_n_bins',10);
p.addParamValue('field_smooth_sd',0);
p.addParamValue('align_starts',true);
p.parse(varargin{:});
opt = p.Results;

comp_ind  = strcmp(rat_conv_table.label,'comp');
ap_ind = strcmp(rat_conv_table.label,'brain_ap');
ml_ind = strcmp(rat_conv_table.label,'brain_ml');

comp_list = rat_conv_table.data(comp_ind,:);
ap_list = rat_conv_table.data(ap_ind,:);
ml_list = rat_conv_table.data(ml_ind,:);

n_trodes = size(rat_conv_table.data,2);

st_fieldsize = struct('comp',{},'ap',{},'ml',{},'fields',{},'disp_centers',{},'phase_pref',{});

for n = 1:n_trodes
    st_fieldsize(n).comp = comp_list{n};
    st_fieldsize(n).ap = ap_list{n};
    st_fieldsize(n).ml = ml_list{n};
end

keep_clust = ones(length(sdat.clust));
for n = 1:length(sdat.clust)
    
    this_cl = sdat.clust{n};
    st_array_ind = strcmp(this_cl.comp, comp_list);
    
    this_field = this_cl.field;
    if(max(this_field.out_rate) > max(this_field.in_rate))
        ratemap = this_field.out_rate;
        twins = pos_info.out_run_bouts;
        this_dir = 1;
    else
        ratemap = this_field.in_rate;
        twins = pos_info.in_run_bouts;
        this_dir = -1;
    end
    [~,keep_log] = gh_times_in_timewins(this_cl.stimes, twins);
    this_cl.stimes = this_cl.stimes(logical(keep_log));
    this_cl.data = this_cl.data(logical(keep_log),:);
    this_cl.nspike = numel(this_cl.stimes);
    
    ratemap = [0, ratemap, 0];
    d_bin = this_field.bin_centers(2) - this_field.bin_centers(1);
    bin_centers = [ min(this_field.bin_centers)-d_bin, this_field.bin_centers, max(this_field.bin_centers) + d_bin];
    [m,i] = max(ratemap);
    start_ind = bin_centers(find(diff(ratemap > opt.field_rate_thresh) ==  1) + 1);
    end_ind   = bin_centers(find(diff(ratemap > opt.field_rate_thresh) == -1) + 1);
    range_bool = logical(bin_centers(i) >= start_ind) & logical(bin_centers(i) <= end_ind);
    field_range = [(start_ind(range_bool)), (end_ind(range_bool))];
    
    st_fieldsize(st_array_ind).fields = [st_fieldsize(st_array_ind).fields; field_range];
    
        % drop clusts too close to the edges
    if(~isempty(opt.edge_limits) && (numel(field_range) > 0))
        if( (field_range(1) < opt.edge_limits(1)) || (field_range(2) > opt.edge_limits(2)))
            keep_clust(n) = 0;
        end
    end
    
    if(m < opt.field_peak_thresh)
        keep_clust(n) = 0;
    end
    
    if(numel(field_range > 0))
    field_edges = linspace(field_range(1),field_range(2),opt.field_n_bins+1);
    disp_centers = cumsum( diff(field_edges)./2 );
    %disp_centers = field_edges(1:end-1) + (field_edges(2)-field_edges(1))/2;
    phase_pref = ones(size(disp_centers));
    phase_ind = strcmp(this_cl.featurenames, 'theta_phase');
    pos_ind =   strcmp(this_cl.featurenames, 'pos_at_spike');
    [~,bin] = histc(this_cl.data(:,pos_ind), field_edges);
    for m = 1:opt.field_n_bins
         this_bool = (bin == m);
         this_phases = this_cl.data(this_bool,phase_ind);
         if(isempty(this_phases))
             phase_pref(m) = 0;  % A HACK.  MAY PRODUCE UGLY RESULTS FOR LOW-SPIKING CELLS
         else
            phase_pref(m) = circ_mean(this_phases);
         end
    end
    if(opt.align_starts)
        if(this_dir == -1)
            % reverse the order of inbound fields
            phase_pref = phase_pref( numel(phase_pref) - [0: (numel(phase_pref) -1 )]);
        end
    else
        disp_centers = field_edges(1:end-1) + (field_edges(2)-field_edges(1))/2;
    end
    %phase_pref = unwrap(phase_pref);
    if(phase_pref(1) >= pi)
        phase_pref = phase_pref - 2*pi;
    end
    if(phase_pref(1) <= -pi*4/2)
        phase_pref = phase_pref + 2*pi;
    end
    end
        
    if(keep_clust(n) == 1)
        st_fieldsize(st_array_ind).disp_centers = [st_fieldsize(st_array_ind).disp_centers; disp_centers];
        st_fieldsize(st_array_ind).phase_pref = [st_fieldsize(st_array_ind).phase_pref; phase_pref];
    end
    
    % drop clusts too close to the edges
    %if(~isempty(opt.edge_limits))
    %    if( (field_range(1) < opt.edge_limits(1)) || (field_range(2) > opt.edge_limits(2)))
    %        keep_clust(n) = 0;
    %    end
    %end
end