%% Test script to decode behavior using the bayesian feature decoder
%% Setup inputs
clear;

args = dset_get_standard_args;
animal = 'Bon';

day = 3;
epoch = 2;

decodingBinWidth = .25;


%% - Load the data

electrodes = 1:30;
amps = dset_load_spike_wave_parameters(animal, day, epoch, electrodes);

%delete empty electrodes
emptyIdx = cellfun( @isempty, amps);
amps = amps( ~emptyIdx );
electrodes = electrodes( ~emptyIdx);

distMat = dset_load_distance_matrix(animal, day, epoch);
pos = dset_load_position(animal, day, epoch);

%% - Setup the function inputs

spikeTime = {};
spikePos = {};
spikeAmp = {};

for i = 1: numel(electrodes)
   spikeAmp{i} = amps{i}(:,2:5);
   spikeTime{i} = amps{i}(:,1);   
   spikePos{i} = interp1(distMat.ts, distMat.positionIdx, spikeTime{i}, 'nearest');
   spikePos{i} = spikePos{i} - 1; % mex file uses 0 indexing correct for this
end

isMoving = abs(pos.smooth_vel) > args.velocityThreshold;
runSegments = logical2seg(pos.ts, isMoving);

posGrid = 1:max(distMat.positionIdx)-1;
posDist{1} = distMat.distMat;

stimBandwidth = 5;
respBandwidth = 30;

stimTime = distMat.ts;
stimPos = distMat.positionIdx - 1; %mex file uses 0 indexing
%% Create the decoder
clear z;
z = kde_decoder(stimTime, stimPos, spikeTime, spikePos, spikeAmp, ...
    'encoding_segments', runSegments, ...
    'stimulus_variable_type', 'linear', ...
    'stimulus_grid', {posGrid}, ...
    'distance', posDist,...
    'stimulus_kernel', 'gaussian', ...
    'stimulus_bandwidth', stimBandwidth, ...
    'response_variable_type', 'linear', ...
    'response_kernel', 'gaussian', ...
    'response_bandwidth', respBandwidth, ...
    'rate_offset', .0001);

%% Do the decoding -- RUN
epochTimes = dset_load_epoch_times(animal, day, epoch);
dt = decodingBinWidth;
timeBins = [ epochTimes(1) : dt : epochTimes(2) - dt ]';
timeBins(:,2) = timeBins + dt;
[P E] = z.compute(timeBins);


%% Do the decoding -- REPLAY
epochTimes = dset_load_epoch_times(animal, day, epoch);
dt = .025;
timeBins = [ epochTimes(1) : dt : epochTimes(2) - dt ]';
timeBins(:,2) = timeBins + dt;
[P E] = z.compute(timeBins);

%% Plot the decoding
plotTs = mean(timeBins,2);
plotPos = interp1(stimTime, stimPos, plotTs, 'nearest');

figure; colormap hot;
imagesc(plotTs, posGrid, P); hold on;

line(plotTs, plotPos, 'color', 'w', 'markersize', 5);