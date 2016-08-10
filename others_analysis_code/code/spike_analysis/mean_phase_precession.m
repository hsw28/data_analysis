function [pos,phase, p_centers, m_phase] = mean_phase_precession(place_cells, varargin)

p = inputParser();  
p.addParamValue('field_buffer',0.2);
p.addParamValue('scale_to_field',false);
p.addParamValue('draw',false);
p.addParamValue('n_p_bins',10);
p.parse(varargin{:});
opt = p.Results;


phase_by_pos = cell(0);
for n = 1:numel(place_cells.clust)
    phase_by_pos = append_spikes(place_cells.clust{n}, opt, phase_by_pos);
end

phase_by_pos = cell2mat(phase_by_pos);
pos = phase_by_pos(1,:);
phase = phase_by_pos(2,:);

if(~isempty(opt.n_p_bins))
    if(~opt.scale_to_field)
        error('phase-binning requires field scaling');
    else
        p_bins = linspace(0,1, opt.n_p_bins);
        p_centers = bin_edges_to_centers(p_bins);
        m_phase = zeros(size(p_centers));
        [~,bin_i] = histc(pos, p_bins);
        for b = 1:numel(p_centers)
            m_phase(b) = gh_circular_mean(phase(bin_i == b),'dim',2);
        end
    end
else
    p_bins = [];
    m_phase = [];
end

if(opt.draw)
    figure;
    hold on;
    cellfun( @(x,y) plot( x(1,:), x(2,:), '.', 'Color', gh_colors(y) ), phase_by_pos, num2cell(1:numel(phase_by_pos)));
end

end




function phase_by_pos2 = append_spikes(clust, opt, phase_by_pos)

this_fields = field_bounds(clust);
outbound = true;
phase_by_pos2 = phase_by_pos;
for n = 1:size(this_fields,2);
    this_field = this_fields(:,n)';
    phase_column = find(strcmp('theta_phase',clust.featurenames),1);
    if(this_field(2) > this_field(1))
        pos_column = find(strcmp(clust.featurenames, 'out_pos_at_spike'),1);
    else
        pos_column = find(strcmp(clust.featurenames, 'in_pos_at_spike'),1);
        outbound = false;
        this_field = this_field([2,1]);
    end
    [~,keep_bool] = gh_times_in_timewins(clust.data(:,pos_column)', this_field + opt.field_buffer * [-1,1]);
    this_pos = clust.data(keep_bool,pos_column)';
    this_phase = clust.data(keep_bool,phase_column)';
    if(~outbound)
        this_pos = -1 * (this_pos - mean(this_field)) + mean(this_field);
    end
    if(opt.scale_to_field)
        this_pos = (this_pos - this_field(1)) ./ diff(this_field);
    end
    phase_by_pos2 = [phase_by_pos2, [this_pos; this_phase] ];
end

end
