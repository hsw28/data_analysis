function r_pos = gh_decode_pos(sdat,pos,varargin)
% R_POS = GH_DECODE_POS(sdat,pos,varargin) reconstruct position from
% sdat is spike dat struct from imspike.m
% pos is a position struct from my linearize_track.m

p = inputParser();
p.addParamValue('r_timewin',[],@isreal);
p.addParamValue('f_timewin',[],@isreal); 
p.addParamValue('f_bins',[]);
p.addParamValue('r_ranges',[]); %override normal time-binning, supply 2xn matrix for n time ranges
p.addParamValue('big_r_ranges',[]); % like r_ranges, but let gh_decode_pos cut ranges into smaller parts
p.addParamValue('n_track_seg',[],@isreal);
p.addParamValue('r_tau',0.025,@isreal);
p.addParamValue('fraction_overlap',0,@isreal);
p.addParamValue('field_direction','outbound');
p.parse(varargin{:});
opt = p.Results;

if(not( 1/(1-opt.fraction_overlap) == floor(1/(1-opt.fraction_overlap))))
    error('fraction_overlap must be (1 - 1/n), n integer.  thank you. eg.  If you want 25pct steps in r_tau, use fraction_overlap 0.75');
end
if(not(isempty(opt.n_track_seg) & isempty(opt.f_timewin)))
    error('gh_decode_pos:n_track_seg_use','Re-calculating place fields not implemented.  Don\''t pass an n_track_seg or f_timewin');
end

r_step = (1 - opt.fraction_overlap)*opt.r_tau;  % step length in sec
n_step_in_r_tau = 1/(1-opt.fraction_overlap); % num steps in an r_tau reconstruction timebin

if(isempty(opt.r_timewin))
    %opt.r_timewin = [min(sdat.clust{1}.stimes),max(sdat.clust{1}.stimes)];
    opt.r_timewin = [min(pos.timestamp),max(pos.timestamp)];
end

tau_edges = opt.r_timewin(1):r_step:opt.r_timewin(2);
n_r_win = numel(tau_edges)-1; % num of r_steps in epoch
n_r_tau_step = n_r_win + 1 - n_step_in_r_tau; % number of r_tau in epoch

nclust = numel(sdat.clust);

% first, generate place fields
field = sdat.clust{1}.field;
if(strcmp(opt.field_direction,'bidirect'))
    n_seg = numel(field.bidirect_rate);
elseif(strcmp(opt.field_direction,'outbound'))
    n_seg = numel(field.out_rate);
elseif(strcmp(opt.field_direction,'inbound'))
    n_seg = numel(field.in_rate);
end

%n_seg = opt.n_track_seg;

%if (n_seg ~= opt.n_track_seg)
%    disp('Recalculating fields...');
%    [sdat,track_info] = assign_field(sdat);
%    disp('Fields calculated.');
%end

% [sdat,track_info] = assign_field(sdat,pos,'timewin',opt.r_timewin','n_track_seg',opt.n_track_seg);

% populate fields matrix, seg by cell
fields = zeros(n_seg,nclust);
for i = 1:nclust
    
    if(strcmp(opt.field_direction,'bidirect'))
        fields(:,i) = sdat.clust{i}.field.bidirect_rate;
    elseif(strcmp(opt.field_direction,'outbound'))
        fields(:,i) = sdat.clust{i}.field.out_rate;
    elseif(strcmp(opt.field_direction,'inbound'))
        fields(:,i) = sdat.clust{i}.field.in_rate;
    end
    fields(fields == 0) = 0.1;
end


field_centers = reshape(field.bin_centers,[],1);
field_dx = field_centers(2)-field_centers(1);
field_starts = field_centers - field_dx/2;
field_ends = field_centers+ field_dx/2;
if(~isempty(opt.f_bins)) % then we have to drop field positions from the rate map
    f_bins = opt.f_bins;
    % set the size of f_bins to 2 x n_bins
    if(min(size(f_bins)) < 2)
        f_bins = [f_bins(1); f_bins(2)];
    else
        if((size(f_bins,1) > 2) || (f_bins(2,1) > f_bins(1,2)))
            f_bins = f_bins';
        end
    end
    n_f_bins = size(f_bins,2);
    n_bin_centers = size(fields,1);
    
    field_after_f_bin_start = repmat(field_starts,1,n_f_bins) >= repmat(f_bins(1,:),n_bin_centers,1);
    field_before_f_bin_end = repmat(field_ends,1,n_f_bins) <= repmat(f_bins(2,:),n_bin_centers,1);
    bin_ok = logical(max(field_after_f_bin_start & field_before_f_bin_end,[],2));
    
    fields = fields(bin_ok,:);
    field_centers = field_centers(bin_ok);
    field_starts = field_starts(bin_ok);
    field_ends = field_ends(bin_ok);
    n_seg = size(fields,1);
end

% override natural reconstruction bounds if asked
if(~isempty(opt.big_r_ranges))
    if(size(opt.big_r_ranges,1) ~= 2)
          error('gh_decode_pos:wrong_big_r_ranges', 'big_r_ranges must be 2 by n');
    end
    % overwrite opt.r_ranges with what we want, and the next code block
    % will take care of the rest
    opt.r_ranges = [];
    for n = 1  : size(opt.big_r_ranges,2)
        this_bins = opt.big_r_ranges(1,n) : opt.r_tau : opt.big_r_ranges(2,n);
        this_ranges = [this_bins(1:(end-1)) ; this_bins(2:end)];
        opt.r_ranges = [opt.r_ranges, this_ranges];
    end
end

% override spike-count matrix if opt.r_ranges given
if(~isempty(opt.r_ranges))
    disp('Warning: using r_ranges or big_r_ranges in gh_decode_pos leads to uninterpretable x-scale in reconstruction!');
    if(size(opt.r_ranges,1) ~= 2)
        error('gh_decode_pos:wrong_r_ranges', 'r_ranges must be 2 by n');
    end
    n_r_win = size(opt.r_ranges,2)*2-1; % n exons, n-1 introns
    n_r_tau_step = n_r_win; % no sliding window in override case
    tau_edges = reshape(opt.r_ranges,1,[]);
end



% populate spike-count matrix.  cells by tau wins
spike_count_steps = zeros(nclust,n_r_win);
spike_count_r_taus = zeros(nclust,n_r_tau_step);
for i = 1:nclust
    this_spike_count = histc(sdat.clust{i}.stimes,tau_edges);
    spike_count_steps(i,:) = this_spike_count(1:end-1);
    for m = 1:n_r_tau_step
        spike_count_r_taus(i,m) = sum(spike_count_steps(i,m:m+n_step_in_r_tau-1));
    end % this loop does the smoothing
end


% setup for the pdf matrix
pdf_by_t = zeros(n_seg,n_r_tau_step);

% loop over track segments.  Not so bad..
% formula: P(x|n) = P(x) * prod over i(field_i(x)^n_i)* exponential_thing
% exponential thing: exp(-tau* sum over i(field_i(x))
% P(x) is the position occpuancy
for i = 1:n_seg
    field_x = sum(fields(i,:));
    expon_part = exp(-1*opt.r_tau*field_x);
    fields_x = fields(i,:)';
    fields_x_tiled = repmat(fields_x,1,n_r_tau_step);
    %a = size(fields_x_tiled)
    %counts = spike_count(i,:);
    %b = size(counts)
    prod_term = prod(fields_x_tiled.^spike_count_r_taus);
    p_x = pos.occupancy.bidirect(i);
    form_this_pos = p_x*prod_term*expon_part;
    %size(form_this_pos);
    pdf_by_t(i,:) = form_this_pos;
end
totals = sum(pdf_by_t);
totals(totals == 0) = 1; % don't want to divide by zero.  TEMPORARY FIX
totals_tiled = repmat(totals,n_seg,1);
pdf_by_t = pdf_by_t ./ totals_tiled;
    
r_pos.pdf_by_t = pdf_by_t;
r_pos.tstart = tau_edges(1);
r_pos.tend = tau_edges(end);
r_pos.ts = linspace(r_pos.tstart, r_pos.tend, size(pdf_by_t,2)+1);
r_pos.ts = mean([r_pos.ts(2:end); r_pos.ts(1:(end-1))]);
r_pos.x_range = [min(pos.lin_filt.data),max(pos.lin_filt.data)];
r_pos.x_vals = field_centers;
r_pos.r_tau = opt.r_tau;
r_pos.fraction_overlap = opt.fraction_overlap;
r_pos.f_bins = opt.f_bins;
r_pos.color = [1 1 1];
r_pos.trode_groups = [];

% take r_pos down to the ranges asked for (drop introns) if overriding
% r_bins
if(~isempty(opt.r_ranges))
    keep_ind = 1:2:size(pdf_by_t,2); % keep odd bins
    r_pos.pdf_by_t  = pdf_by_t(:,keep_ind);
    r_pos.ts = mean(opt.r_ranges,1);
end