function [results_mat, compensation_amount, f] = shift_reconstruct(place_cells, pos_info, rat_conv_table, mod_opt, reconstruct_opt, varargin)
% results_mat = SHIFT_RECONSTRUCT(place_cells, mod_opt, ['compensation_amount', [-1.5 : 0.1 : 1.5] ],
%                                                          ['hist_bin_edges', [0 : 0.05 : 1] ],                                                             
%                                                          
% Repeatedly perform reconstruction, after shifting each place cells's
% spikes by an amount related to the phase offset in that spike's tetrode's
% LFP theta.  Collect distribution of reconstruction quality for each shift
% case
% 

p = inputParser();
p.addParamValue('compensation_amount', [-1.5 : 0.1 : 1.5]);
p.addParamValue('hist_bin_edges', [0 : 0.05 : 1] );
p.addParamValue('summary_statistic', 'p_at_mode', @(x) any(strcmp(x,{'p_at_mode','entropy'})));
p.addParamValue('ok_score_range', [0, Inf]);
p.addParamValue('draw',true);
p.parse(varargin{:});
opt = p.Results;

f = 0;
compensation_amount = opt.compensation_amount;

results_mat = zeros( numel(opt.hist_bin_edges)-1, numel(opt.compensation_amount));
results_mean = zeros(1, numel(opt.compensation_amount));

for n = 1:numel(opt.compensation_amount)
    disp(['Working on compensation_amount: ', num2str(opt.compensation_amount(n))]);
    this_shift_place_cells = shift_sdat(place_cells, rat_conv_table, mod_opt, 'compensation', opt.compensation_amount(n));
    
    field_dir_bool = cellfun(@(x) ischar(x) && strcmp(x, 'field_direction'), reconstruct_opt);
    if(any(field_dir_bool) && ~isempty(reconstruct_opt{ find(field_dir_bool, 1, 'first') } ))
        % there is a non-empty 'field_direction' option, so use that 
        r_pos = gh_decode_pos(this_shift_place_cells, pos_info, reconstruct_opt{:});

    else
        % user didn't request a field-dir.  So first do outbound_dir fields
        % at outbound_dir timewins, then inbound-inbound, and concat the
        % pdf's horizontally
        r_pos_out = gh_decode_pos(this_shift_place_cells, pos_info, reconstruct_opt{:}, ...
            'field_direction', 'outbound', 'big_r_ranges', pos_info.out_run_bouts');
        r_pos_in = gh_decode_pos(this_shift_place_cells, pos_info, reconstruct_opt{:},...
            'field_direction', 'inbound', 'big_r_ranges', pos_info.in_run_bouts');
        r_pos = r_pos_out;
        r_pos.pdf_by_t = [r_pos_out.pdf_by_t, r_pos_in.pdf_by_t ];
    end
    numel(opt.compensation_amount)
        
    if(strcmp('p_at_mode',opt.summary_statistic))
        this_res = reconstruction_p_at_mode(r_pos);
    elseif(strcmp('entropy', opt.summary_statistic))
        this_res = reconstruction_entropy(r_pos);
    else
        error('shift_reconstruct:unrecognized_summary_statistic',...
              ['In shift_reconstruct, could not recognize summary statistic: ',...
                opt.summary_statistic]);
    end
    
    if(~isempty(opt.ok_score_range))
        this_res = this_res( (this_res >= min(opt.ok_score_range)) & ...
            (this_res <= max(opt.ok_score_range)) );
    end
        
    summary_stat_distribution = histc(this_res, opt.hist_bin_edges);
    results_mat(:,n) = summary_stat_distribution(1:(end-1))';
    results_mean(n) = mean(this_res);
    
end

if(opt.draw)
    score_vals = bin_edges_to_centers(opt.hist_bin_edges);
    f = imagesc([min(opt.compensation_amount), max(opt.compensation_amount)],...
                [min(score_vals), max(score_vals)],...
                log(results_mat));
    hold on;
    plot([0, 0], [min(score_vals), max(score_vals)],'k-');
    plot([1, 1], [min(score_vals), max(score_vals)],'w-');
 
    plot(opt.compensation_amount, results_mean);
end