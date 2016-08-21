function [p e] = dset_calculate_bilateral_decoding_errors_run(dset)

tetInfo = dset.amp.info;
tetInfo = tetInfo(1:29);
[spA, spT, spP, pG, dM, stT, stP, eS] = dset_setup_amplidute_decoding_inputs(dset);
emptyElectrodes = cellfun(@isempty, spT);

idxL = strcmp({tetInfo.hemisphere}, 'left') & ~emptyElectrodes;
idxR = strcmp({tetInfo.hemisphere}, 'right') & ~emptyElectrodes;

%for i = 1:numel(idxL)
%    if size(spT{i}) < 

idxA = idxL | idxR;
%% Setup the decoders
zLeft = kde_decoder(stT, stP, spT(idxL), spP(idxL), spA(idxL), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', .001);

zRight = kde_decoder(stT, stP, spT(idxR), spP(idxR), spA(idxR), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', .001);

zAll = kde_decoder(stT, stP, spT(idxA), spP(idxA), spA(idxA), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', .001);

%%

dt = .25;
decodingBins = [ dset.epochTime(1):dt:dset.epochTime(2) - dt ]';
decodingBins(:,2) = decodingBins + dt;

vel = interp1(dset.position.ts, dset.position.smooth_vel, decodingBins(:,1));
isMovingIdx = abs(vel)>10;

decodingBins = decodingBins(isMovingIdx,:);
%%
[p.left e.left]   = zLeft.compute(decodingBins);
[p.right e.right] = zRight.compute(decodingBins);
[p.all e.all]     = zAll.compute(decodingBins);


%% Create the shuffle decoders
shuffledSpikePos = spP;
for i =1:numel(shuffledSpikePos) % shuffle spike times
    if ~isempty(spP{i})
        shuffledSpikePos{i} = randsample(spP{i}, numel(spP{i}) );
    end
end

spP_LS = spP;
spP_LS(idxL) = shuffledSpikePos(idxL);
spP_RS = spP;
spP_RS(idxR) = shuffledSpikePos(idxR);
% stP_shuff = randsample(stP, numel(stP));

%% Shuffle spike responses

spA_shuff = spA;
for i =1:numel(spA)
    amps = spA{i};
    amps = amps(randsample(size(amps,1), size(amps,1)),:);
    spA_shuff{i} = amps;
end

ampShufRight = spA;
ampShufRight(idxR) = spA_shuff(idxR);
ampShufLeft = spA;
ampShufLeft(idxL) = spA_shuff(idxL);

%%
zLShuffle = kde_decoder(stT, stP, spT(idxA), spP_LS(idxA), ampShufLeft(idxA), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', .001);



zRShuffle = kde_decoder(stT, stP, spT(idxA), spP_RS(idxA), ampShufRight(idxA), 'encoding_segments', eS,...
    'stimulus_variable_type', 'linear', 'stimulus_grid', {pG}, ...
    'distance', dM, 'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
    'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
    'rate_offset', .001);


[p.shuffleLeft e.shuffleLeft] = zLShuffle.compute(decodingBins);
[p.shuffleRight e.shuffleRight] = zRShuffle.compute(decodingBins);


