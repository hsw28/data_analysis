function [p] = dset_calculate_bilateral_decoding_replay_trajectories(dset)

tetInfo = dset.amp.info;
tetInfo = tetInfo(1:29);
[spA, spT, spP, pG, stT, stP, eS] = ...
     dset_setup_amplitude_decoding_inputs_seperate_trajectories(dset);
 
 
emptyElectrodes = cellfun(@isempty, spT);

idxL = strcmp({tetInfo.hemisphere}, 'left') & ~emptyElectrodes;
idxR = strcmp({tetInfo.hemisphere}, 'right') & ~emptyElectrodes;

%for i = 1:numel(idxL)
%    if size(spT{i}) < 

idxA = idxL | idxR;

rateOffset = .0001;

for traj = 1:numel(stP)
    zLeft(traj) = kde_decoder(stT{traj}, stP{traj}, spT(idxL), spP(idxL), spA(idxL), 'encoding_segments', eS{traj},...
        'stimulus_variable_type', 'linear', 'stimulus_grid', pG(traj), 'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
        'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
        'rate_offset', rateOffset);

    zRight(traj) = kde_decoder(stT{traj}, stP{traj}, spT(idxR), spP(idxR), spA(idxR), 'encoding_segments', eS{traj},...
        'stimulus_variable_type', 'linear', 'stimulus_grid', pG(traj), 'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
        'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
        'rate_offset', rateOffset);

    zAll(traj) = kde_decoder(stT{traj}, stP{traj}, spT(idxA), spP(idxA), spA(idxA), 'encoding_segments', eS{traj},...
        'stimulus_variable_type', 'linear', 'stimulus_grid', pG(traj), 'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', 30, 'response_variable_type', 'linear',...
        'response_kernel', 'gaussian', 'response_bandwidth', 5, ...
        'rate_offset', rateOffset);
    
end

%% Setup the decoders

%%

dt = .025;
decodingBins = [ dset.epochTime(1):dt:dset.epochTime(2) - dt ]'; %#ok
decodingBins(:,2) = decodingBins + dt;

%%

for i = 1:numel(stP)
    p.left{i} = zLeft(i).compute(decodingBins);
    p.right{i} = zRight(i).compute(decodingBins);
    p.all{i} = zAll(i).compute(decodingBins);
    p.pbins{i} = pG{i};
end
p.tbins = decodingBins;




