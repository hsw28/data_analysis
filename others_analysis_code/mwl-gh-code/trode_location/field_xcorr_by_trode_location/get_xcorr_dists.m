function [xcorr_dists, xcorr_maxr, xcorr_mat,lags] = get_xcorr_dists(fieldClusts, field_cells, fields, d, varargin)

p = inputParser();
p.addParamValue('timebouts', [min( cellfun(@(x) min(x.stimes), fieldClusts)), ...
    max(cellfun(@(x) max(x.stimes), fieldClusts))]);
p.addParamValue('xcorr_bin_size',0.002);
p.addParamValue('xcorr_lag_limits', [-0.06, 0.06]);
p.addParamValue('r_thresh', 1e-3);
p.addParamValue('drop_diagonal',true);
p.addParamValue('smooth_timewin',0.01);
p.addParamValue('field_dists',[]);
p.addParamValue('xcorr_mat',[]);
p.addParamValue('draw_pairs',[]);
p.parse(varargin{:});
opt = p.Results;


% From each fieldClust, drop the spikes that aren't part of this field.
% This only works with the above monkeypatch in place.
first_inbound_ind = numel(fields{1})/2 + 1;
bin_c = fieldClusts{1}.field.bin_centers;
for n = 1:numel(fieldClusts)
    field = fields{n};
    if(sum(fields{n}(1:(first_inbound_ind-1))) > 0)
        bouts = d.pos_info.out_run_bouts;
    elseif(sum(fields{n}(first_inbound_ind:end)) > 0)
        bouts = d.pos_info.in_run_bouts;
    else
        error('get_xcorr_dists:bad_field','Bad field for cell');
    end
    bidirect_rates = field(1:(first_inbound_ind-1)) ...
        + field(end:-1:first_inbound_ind);
    field_start = bin_c(find(bidirect_rates > 0,1,'first'));
    field_end   = bin_c(find(bidirect_rates > 0,1,'last'));
    stimes = fieldClusts{n}.stimes;
    pos_at_spike = interp1(conttimestamp(d.pos_info.lin_filt),...
        d.pos_info.lin_filt.data, stimes);
    keep = gh_points_are_in_segs(fieldClusts{n}.stimes, bouts) & ...
        pos_at_spike >= field_start & pos_at_spike <= field_end;
    fieldClusts{n}.stimes = fieldClusts{n}.stimes(keep);
    fieldClusts{n}.data = fieldClusts{n}.data(keep,:);
end

n_cells  = numel(fieldClusts);
n_fields = numel(field_cells);
n_timebouts = size(opt.timebouts,1);

time_bin_edges = min(min(opt.timebouts)) : opt.xcorr_bin_size : max(max(opt.timebouts));
time_bin_dt = time_bin_edges(2) - time_bin_edges(1);
time_bin_edges = [time_bin_edges, (time_bin_edges(end) + time_bin_dt)];
n_time_bin_edges = numel(time_bin_edges);
opt.time_bouts(:,1) = interp1( time_bin_edges, time_bin_edges, opt.timebouts(:,1),'nearest');
opt.time_bouts(:,2) = interp1( time_bin_edges, time_bin_edges, opt.timebouts(:,2),'nearest');
ind_bouts = ones(size(opt.timebouts));
ind_bouts(:,1) = interp1(time_bin_edges, 1:n_time_bin_edges, opt.timebouts(:,1), 'nearest');
ind_bouts(:,2) = interp1(time_bin_edges, 1:n_time_bin_edges, opt.timebouts(:,2), 'nearest');
ind_lengths = diff(ind_bouts,[],2) + 1;
keep_bool = ind_lengths >= diff(opt.xcorr_lag_limits);
ind_bouts = ind_bouts(keep_bool,:);
ind_lengths = ind_lengths(keep_bool);
ind_bouts = mat2cell(ind_bouts, ones(size(ind_bouts,1),1), 2);
ind_expansion = cellfun( @(x) (x(1):x(2)), ind_bouts','UniformOutput', false);
% ind_expansion is a row vector because of the transpose on ind_bouts
ind_expansion = cell2mat(ind_expansion);
ind_expansion = ind_expansion;


%  NEW WAY - SHOULD BE FASTER %
% make rates_cell cell(size n_cells,1), each cell is rates (size 1,n_rates)

opt.lag_times = opt.xcorr_lag_limits(1) : opt.xcorr_bin_size : opt.xcorr_lag_limits(2);
if( mod(numel(opt.lag_times) ,2 ) == 0)
    error('get_xcorr_dists:wrong_lag_limits_and_bin_size','Try different xcorr_bin_size and xcorr_lag_limits.');
end
opt.max_lags = (numel(opt.lag_times) - 1)/2;

if(isempty(opt.smooth_timewin))
    opt.smooth_n_bins = 1;
    sm_krn = 1;
    sm_cof = 1;
else
    opt.smooth_n_bins = opt.smooth_timewin / opt.xcorr_bin_size;
    sm_krn = ones(1, opt.smooth_n_bins);
    sm_cof = 1/ sum(sm_krn);
end

rates_cell = cellfun( @(x) sm_cof .* conv(reshape(histc(x.stimes, time_bin_edges),1,[]),sm_krn,'same' ),  ...
    reshape(fieldClusts,[],1),'UniformOutput', false);
rates_array = cell2mat(rates_cell);
rates_array_broken_into_bouts = rates_array(:, ind_expansion);

n_time = size(rates_array_broken_into_bouts,2);

rates_array_bouts_concat = mat2cell(rates_array_broken_into_bouts,...
        ones(n_cells,1), n_time);
%big_rates_array = repmat(rates_array_bouts_concat, 1, n_cells);

%if(~isempty(opt.field_dists))
%    big_rates_array( isnan(opt.field_dists) ) = {NaN};
%end

XX = repmat([1:n_fields]',1,n_fields);
YY = repmat([1:n_fields], n_fields,1);
if(~isempty(opt.field_dists))
    isOk = ~isnan(opt.field_dists);
else
    isOk = ones(size(XX));
end

r = arrayfun( @(x,y,k) lfun_new_xcorr(rates_array_bouts_concat{x},rates_array_bouts_concat{y},k,opt),  ...
        XX, YY, isOk, 'UniformOutput', false);
xcorr_mat = r;    

xcorr_dists = cellfun( @(x) lfun_xcorr_best_time(x,opt), r);
xcorr_maxr = cellfun( @max, r);
lags = opt.lag_times;

for n = 1:size(opt.draw_pairs,1)
    figure; subplot(2,1,1);
    this_a = fieldClusts{opt.draw_pairs(n,1)};
    this_b = fieldClusts{opt.draw_pairs(n,2)};
    plot( this_a.field.bin_centers, this_a.field.out_rate, 'b'); hold on;
    plot( this_a.field.bin_centers, -1.*this_a.field.in_rate, 'b');
    plot(this_b.field.bin_centers, this_b.field.out_rate,'r');
    plot(this_b.field.bin_centers, -1.*this_b.field.in_rate, 'r');
    ylim([-40 40]);
    title([ num2str(opt.draw_pairs(n,1)), ' by ', num2str(opt.draw_pairs(n,2))]);
    ylabel('Place Field');
    subplot(2,1,2);
    this_r = reshape(r{opt.draw_pairs(n,1), opt.draw_pairs(n,2)}, 1, []);
    plot( opt.lag_times, this_r );
    xlabel('Time lag(s)');
     ylabel('correlation');
    
end

if(~isempty( opt.r_thresh) )
    xcorr_dists( xcorr_maxr < opt.r_thresh ) = NaN;
end

if(opt.drop_diagonal)
    diag_logicals = logical( eye(size(xcorr_dists)) );
    %r( diag_logicals ) = {NaN};
    xcorr_dists( diag_logicals ) = NaN;
    xcorr_maxr ( diag_logicals ) = NaN;
end


end

function r_cell = lfun_new_multibout_xcorr(multbouts_ratesA, multibouts_ratesB, opt)
    r_cell = cellfun( @(x,y) lfun_new_xcorr(x,y,opt), ...
        multibouts_ratesA, multibouts_ratesB, 'UniformOutput', false);

end

function r = lfun_new_xcorr(ratesA, ratesB, thisIsOk, opt)
    if( all(~isnan(ratesA)) && all(~isnan(ratesB)) && thisIsOk )
        r = xcorr(ratesA,ratesB, opt.max_lags, 'unbiased')./opt.xcorr_bin_size;
    else
        r = NaN;
    end
end

function this_best_time = lfun_xcorr_best_time(r, opt)
    if(max(r) >= opt.r_thresh)
        this_best_time = opt.lag_times(r == max(r));
        this_best_time = this_best_time(1);  % if ththisere are multiple peaks, pick the earliest one
    else
        this_best_time = NaN;
    end
end

% local funs for old way

function r = lfun_xcorr_this_bout(counts_matA, counts_matB, this_bout_inds)
    %cellfun(@(x) xcorr(A

end


function r = lfun_xcorr_multibouts(cellA, cellB, opt)
    if(or( ~cellA.has_field, ~cellB.has_field))
        r = NaN * ones(1, (2*opt.max_lags)+1);
        return;
    end
    n_bouts = size(opt.timebouts,1);
    bouts_cell = mat2cell(opt.timebouts, ones(n_bouts,1), 2);
    bouts_cell = reshape(bouts_cell,[],1); % make bouts cell column vector
    % dim1, bout, dim2 time
    r_each_timebout = cellfun( @(x) lfun_xcorr(cellA, cellB, x, opt), bouts_cell, 'UniformOutput',false);
    r = mean( cell2mat(r_each_timebout), 1);
end

function r = lfun_xcorr(cellA,cellB, this_bout, opt)
    time_edges = this_bout(1) : opt.xcorr_bin_size : this_bout(2);
    rateA = histc(cellA.stimes, time_edges);
    rateB = histc(cellB.stimes, time_edges);
    r = xcorr(rateA, rateB, opt.max_lags, 'unbiased')./opt.xcorr_bin_size;
    r = reshape(r, 1,[]);  % make r a row vector
    r = conv(r, 1/opt.smooth_n_bins.*ones(1,opt.smooth_n_bins),'same');
end