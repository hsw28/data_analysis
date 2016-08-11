function f = gh_plot_rpos_stack(r_pos_s,r_pos_all_s,pos_info,varargin)

p = inputParser();
% possible values for 'allign_on':
% 'mode1','mode2','mode3','expectation1','expectation2','position',
%'mean_of_modes','all_cells_mode','all_cells_expectation'
p.addParamValue('allign_on','mode2');
p.addParamValue('draw_pdfs',false);
p.addParamValue('mode_hist_bins',[]);
p.addParamValue('all_units_rpos',[]);
p.addParamValue('output_summary','mode'); % possible values: 'mode','expectation'
p.addParamValue('norm_y',false);
p.parse(varargin{:});
opt = p.Results;

% default mode_hist_bins
if(isempty(opt.mode_hist_bins))
    opt.mode_hist_bins = linspace(-1, 1, 50);
end

mode_hist_binsize = opt.mode_hist_bins(2) - opt.mode_hist_bins(1);
mode_hist_bin_centers = mean( [opt.mode_hist_bins(2:end) ; ...
                               opt.mode_hist_bins(1:(end-1))], 1 );

mode_hist_fig = gcf();

% mode_hist.  One row for each pdf_by_t in the multi_r_pos and one column
% for each relative position on the track
pdf_marg_hist = zeros(numel(r_pos_s), numel(opt.mode_hist_bins)-1);
pdf_marg_list = zeros(numel(r_pos_s), size(r_pos_s(1).pdf_by_t,2) );
p_list = zeros(size(pdf_marg_list));
p_list_all = zeros(1,size(r_pos_s(1).pdf_by_t,2));

if(opt.draw_pdfs)
    pdfs_fig = figure;
end

n_r_pos_stims = size(r_pos_s(1).pdf_by_t,1);
n_r_pos_times = size(r_pos_s(1).pdf_by_t,2);
n_chans = numel(r_pos_s);
r_pos_s_expectation = zeros(n_chans,n_r_pos_times);
r_pos_s_mode        = zeros(n_chans,n_r_pos_times);

r_pos_all_expectation = r_pos_all_s(1).x_vals' * r_pos_all_s(1).pdf_by_t;
r_pos_all_match_max = r_pos_all_s(1).pdf_by_t == repmat(max(r_pos_all_s(1).pdf_by_t,[],1),n_r_pos_stims,1);
r_pos_all_first_match = (diff(cumsum([zeros(1,n_r_pos_times);r_pos_all_match_max],1),1) > 0) == 1;
stim_grid = repmat( r_pos_s(1).x_vals, 1, n_r_pos_times );
r_pos_all_mode = reshape( stim_grid(logical(r_pos_all_first_match)),1,[]);
r_pos_all_mode        = r_pos_all_s(1).pdf_by_t;
p_list_all = reshape( r_pos_all_s(1).pdf_by_t(logical(r_pos_all_first_match)),1,[] );

for n = 1:n_chans
    r_pos_s_expectation(n,:) = r_pos_s(1).x_vals' * r_pos_s(n).pdf_by_t;
end
    
expectation_diffs = r_pos_s_expectation - repmat(r_pos_all_expectation,n_chans,1);

for n = 1:n_chans
    this_counts = histc(expectation_diffs(n,:), opt.mode_hist_bins);
    pdf_marg_hist(n,:) = this_counts(1:(end-1));
    plot(mode_hist_bin_centers,pdf_marg_hist(n,:),'-','Color',r_pos_s(n).color);
    hold on;
end

% 
% for m = 1:(numel(r_pos_s))
%     %time_ind_multi = 1;
%     %time_ind_all = find(lfun_find_matching_time_index(
%     pdf_offset = lfun_pdf_offset(r_pos_s(m), opt);
%     
%     if(opt.draw_pdfs)
%         figure(pdfs_fig);
%         for n = 1:(numel(r_pos_s(n).multi_r_pos))
%             plot( r_pos_stack(m).multi_r_pos(n).x_values' - pdf_offset,...
%                   r_pos_stack(m).multi_r_pos(n).pdf_by_t(:,1)','-',...
%                   'Color',r_pos_stack(m).multi_r_pos(n).color );
%         end
%     end
%     
%     for mode_num = 1:numel(r_pos_stack(m).multi_r_pos)
%         %time_ind = find(lfun_find_matching_time_index(
%         mode_list(mode_num,m) = lfun_mode(r_pos_stack(m).multi_r_pos, mode_num, 1) - pdf_offset;
%         
%         %this_hist = histc( expectation(r_pos_stack(m).multi_r_pos(mode_num).x_expectation(r_pos_stack.multi_r_pos(mode_num).pdf_by_t(:,1)', ...
%         %                 r_pos_stack(m).multi_r_pos(mode_num).x_vals').vals',...
%         %                 r_pos_stack(m).multi_r_pos(mode_num).pdf_by_t(:,1)'),...
%         %                 opt.mode_hist_bins);
%         
%                      %mode_hist(mode_num,:) = mode_hist(mode_num,:) +...
%         %    histc( expectation(r_pos_stack(m).multi_r_pos(mode_num).x_expectation(r_pos.multi_r_pos(mode_num).pdf_by_t(:,1)',...
%         %                 r_pos.multi_r_pos(mode_num).x_vals').vals',...
%         %                 r_pos_stack(m).multi_r_pos(mode_num).pdf_by_t(:,1)'),...
%         %                 opt.mode_hist_bins);
%     end
%     
%     % histc each channel of the multi_r_pos'es
%     for mode_num = 1:numel(r_pos_stack(1).multi_r_pos)
%         mode_hist(mode_num,:) = histc(mode_list(mode_num,:), opt.mode_hist_bins);
%     end
% end
% 
% figure(mode_hist_fig);
% for n = 1:numel(r_pos_stack(1).multi_r_pos)
%     % add the last column to the second-to-last column for the final
%     % hist presentation
%     this_bin_counts = mode_hist(n,(1:end-1));
%     this_bin_counts(end) = this_bin_counts(end) + mode_hist(n,end);
%     if(opt.norm_y)
%         this_bin_counts = this_bin_counts ./ sum(this_bin_counts);
%     end
%     plot(mode_hist_bin_centers, this_bin_counts, '-',...
%         'Color',r_pos_stack(1).multi_r_pos(n).color);
%     hold on;
% end
    



function pdf_offset = lfun_pdf_offset(r_pos, opt)
if(strcmp('mode', opt.allign_on(1:4)))
    mode_num = str2num(opt.allign_on(5:end));
    max_ind = r_pos.multi_r_pos(mode_num).pdf_by_t(:,1) == ...
        max(r_pos.multi_r_pos(mode_num).pdf_by_t(:,1));
    max_ind = find(max_ind, 1,'first');
    pdf_offset = r_pos.multi_r_pos(mode_num).pdf_by_t(max_ind,1); 
    return;
end

if(strcmp('expectation',opt.allign_on(1:11)))
    expect_num = str2num(opt.allign_on(12:end));
    pdf_offset = lfun_expectation(r_pos.multi_r_pos(expect_num).pdf_by_t(:,1)',...
                             r_pos.multi_r_pos(expect_num).x_vals');
    return;
end

if(strcmp('mean_of_modes', opt.allign_on))
    mode_array = zeros(1,numel(r_pos));
    for n = 1:numel(r_pos)
        mode_array(n) = lfun_mode(r_pos, n, ...
            lfun_find_matching_time_index(r_pos, r_pos.trigger_time));
    end
    pdf_offset = mean(mode_array);
    return;
end

if(strcmp('position',opt.allign_on))
    pdf_offset = r_pos.track_position;
    return;
end

if(strcmp('all_cells_r_pos_mode', opt.allign_on))
    trig_logicals = lfun_find_matching_time_index(opt.all_cells_r_pos, ...
        r_pos.trigger_time);
    pdf_offset = lfun_mode(all_cells_r_pos,1,find(trig_logicals));
    return;
end

if(strcmp('all_cell_r_pos_expectation', opt.allign_on))
    trig_logicals = lfun_find_matching_time_index(opt.all_cells_r_pos, ...
        r_pos.trigger_time);
    pdf_offset = lfun_expectation(opt.all_cells_r_pos.pdf_by_t(:,trig_logicals),...
        opt.all_cells_r_pos.x_values);
    return;
end
    
pdf_offset = 0;
return;

function val = lfun_expectation(y,x)
val = sum(x.*y);

function [the_mode, the_p] = lfun_mode(r_pos, r_pos_ind ,time_ind)
p = r_pos(r_pos_ind).pdf_by_t(:,time_ind);
the_p = max(p);
the_mode = r_pos(r_pos_ind).x_vals( p == max(p) );
the_mode = the_mode(1);
return;

function logicals = lfun_find_matching_time_index(r_pos, time_value)
ts = linspace(r_pos.tstart, r_pos.tend, size(r_pos.pdf_by_t,2)+1);
% the +1 is because tstart and tend are the outer edges of the timebins
logicals = abs(ts - time_value) == (min(abs(ts - time_value)));
return;