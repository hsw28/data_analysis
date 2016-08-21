function [p] = dset_calculate_bilateral_decoding_replay(dset)

tetInfo = dset.amp.info;
tetInfo = tetInfo(1:29);
[spA, spT, spP, pG, dM, stT, stP, eS] = dset_setup_amplidute_decoding_inputs(dset);
emptyElectrodes = cellfun(@isempty, spT);

idxL = strcmp({tetInfo.hemisphere}, 'left') & ~emptyElectrodes;
idxR = strcmp({tetInfo.hemisphere}, 'right') & ~emptyElectrodes;

rateOffset = .0001;
%for i = 1:numel(idxL)
%    if size(spT{i}) < 

idxA = idxL | idxR;
%% Setup the decoders
zLeft = kde_decoder(stT, stP, spT(idxL), spP(idxL), spA(idxL), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', rateOffset);

zRight = kde_decoder(stT, stP, spT(idxR), spP(idxR), spA(idxR), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', rateOffset);

zAll = kde_decoder(stT, stP, spT(idxA), spP(idxA), spA(idxA), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', rateOffset);

%%

dt = .025;
decodingBins = [ dset.epochTime(1):dt:dset.epochTime(2) - dt ]';
decodingBins(:,2) = decodingBins + dt;

%%
[p.left]   = zLeft.compute(decodingBins);
[p.right] = zRight.compute(decodingBins);
[p.all]     = zAll.compute(decodingBins);
p.tbins = decodingBins;
p.pbins = pG;

