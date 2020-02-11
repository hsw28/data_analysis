function [P,M,nspikes,ntestspikes,nrespdim]=compute_source(src,bins,timestamp,testresponse,sp_stimulus,sp_response,stimgrid,state,distlut, stim_marginal, training_duration,flt_idx)
%COMPUTE_SOURCE compute KDE rate and marginal rate for single source
%
%  [P,M,nspikes,ntestspikes,nrespdim]=COMPUTE_SOURCE(src,bins,timestamp,test_resp,spike_stim,spike_resp,stimgrid,state,distlut,stim_marginal,training_duration,flt_idx)
%


nbins = size(bins,1);
combined_bins = seg_or(bins);

%do response randomization
if islogical(state.response_randomization) && state.response_randomization
    sp_response = randomize(sp_response,1,2);
elseif isa( state.response_randomization, 'function_handle')
    sp_response = state.response_randomization( sp_response );
end
%do response selection
resp_kernel = state.response_kernel{src}(state.response_selection{src});
resp_bandwidth = state.response_bandwidth{src}(state.response_selection{src});
sp_response = sp_response(:,state.response_selection{src});

%do post response filter
post_flt_idx = state.response_filter_post(sp_response,src);
sp_response = sp_response(post_flt_idx,:);
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

%test response filtering
if nargin<12 || isempty(flt_idx)
    flt_idx = state.response_filter(testresponse,src);
end
%test response transformation
testresponse = state.response_transformation(testresponse(flt_idx,:));
%test response selection
testresponse = testresponse( :, state.response_selection{src} );
%test response normalization
testresponse = bsxfun( @rdivide, testresponse(:,resp_kernel~=3), resp_bandwidth(resp_kernel~=3) );
%timestamp filtering
timestamp = timestamp(flt_idx,:);

%post test response filter
post_flt_idx = state.response_filter_post(testresponse,src);
testresponse = testresponse(post_flt_idx,:);
timestamp = timestamp(post_flt_idx,:);

%gather info
nspikes = size( sp_stimulus, 1);
ntestspikes = size( testresponse, 1);
nrespdim = size( testresponse, 2);

grid_size = size(stimgrid,1);

%pre-allocate arrays
P = zeros(nbins,grid_size);
C = zeros(nbins,1);
M = zeros(1,grid_size);

%check valid grid points
valid_grid = ~isnan( stimgrid(:,1) );
stimgrid = stimgrid( valid_grid, :);
P(:,~valid_grid)=NaN;
M(~valid_grid) = NaN;

%get function handle
f = kde_decoder.get_func( stim_kernel, resp_kernel );

%find all test response spike inside bins
spike_idx = find(fast_inseg( combined_bins, timestamp ));

%compute the offset to apply
mu = nspikes./training_duration;
ofs = state.rate_offset.*stim_marginal(valid_grid)./mu;

%arbitrary maximum of 10M elements in intermediate array
blocksize = round( 10000000./grid_size );
nblocks = ceil( numel(spike_idx) ./ blocksize );
indices = min( [blocksize.*(0:(nblocks-1))+1 ; blocksize.*(1:nblocks)]', numel(spike_idx) ); %#ok

for b=1:nblocks
    bi1 = find( bins(:,1)<timestamp(spike_idx(indices(b,1))), 1, 'last');
    bi2 = find( bins(:,2)>timestamp(spike_idx(indices(b,2))), 1, 'first');
    
    if isempty(bi1), bi1=1; end
    if isempty(bi2), bi2=nbins; end
    
    ii = spike_idx( indices(b,1):indices(b,2) );
    
    [o1,o2] = f( sp_stimulus, stimgrid, stim_kernel, stim_bandwidth, sp_response, resp_kernel, resp_bandwidth, testresponse(ii,:), ofs, distlut, timestamp(ii), bins(bi1:bi2,:) );
    
    P(bi1:bi2,valid_grid) = P(bi1:bi2,valid_grid) + o1;
    C(bi1:bi2,1) = C(bi1:bi2,1) + o2;
    
end

%compute marginal probability
f = kde_decoder.get_func( stim_kernel, [] );
M(valid_grid) = f( sp_stimulus, stimgrid, stim_kernel, stim_bandwidth, [], [], zeros(0,1), zeros(1,0), ofs, distlut );
M = exp(M);
M = M./nansum(M(:));

%compute marginal rate
M = (nspikes.*M)./(training_duration.*stim_marginal);

%compute log(rate)
P = P - bsxfun( @times, C, log(stim_marginal) );

end