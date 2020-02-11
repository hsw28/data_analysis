function M=compute_source_tuning(src,sp_stimulus,sp_response,stimgrid,state,distlut,stim_marginal,training_duration)

% %do response randomization
% if islogical(state.response_randomization) && state.response_randomization
%     sp_response = randomize(sp_response,1,2);
% elseif isa( state.response_randomization, 'function_handle')
%     sp_response = state.response_randomization( sp_response );
% end
%do response selection
sp_response = sp_response(:,state.response_selection{src});

%do post response filter
post_flt_idx = state.response_filter_post(sp_response,src);
sp_stimulus = sp_stimulus(post_flt_idx,:);

%get stimulus kernel
stim_kernel = state.stimulus_kernel;
stim_bandwidth = state.stimulus_bandwidth;

%scale grid by kernel bandwidth, but only for dimensions for which the kernel
%is not von mises and no distance matrix is provided
ni = cellfun( @(x) size(x,1), distlut(:)' );
idx = ni==0 & stim_kernel~=3;
if sum(idx)>0
    stimgrid( :, idx ) = bsxfun( @rdivide, stimgrid(:, idx ), stim_bandwidth(idx) );
end

%gather info
nspikes = size( sp_stimulus, 1);

grid_size = size(stimgrid,1);

%pre-allocate arrays
M = zeros(1,grid_size);

%check valid grid points
valid_grid = ~isnan( stimgrid(:,1) );
stimgrid = stimgrid( valid_grid, :);
M(~valid_grid) = NaN;

%compute the offset to apply
mu = nspikes./training_duration;
ofs = state.rate_offset.*stim_marginal(valid_grid)./mu;


%compute marginal probability
f = kde_decoder.get_func( stim_kernel, [] );
M(valid_grid) = f( sp_stimulus, stimgrid, stim_kernel, stim_bandwidth, [], [], zeros(0,1), zeros(1,0), ofs, distlut );
M = exp(M);

%compute marginal rate
M = (nspikes.*M)./(training_duration.*stim_marginal);