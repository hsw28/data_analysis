function [P, E, input] = decode_feature_realtime(baseDir, nChan)
%% Load DATA

if ~exist(baseDir,'dir');
    error('Invalid directory specified');
end


input.description = baseDir;

%%%%%%%%%%%% DECODING PARAMETERS %%%%%%%%%%%%
decodeDT = .25;     % time bin width for decoder
decodeDP = .1;      % position bin width for decoding
minVelocity = .15;  % minimun velocity for spikes to be used for encoding
stimulusBandwidth = .1; 
responseBandwidth = 30;

%%%%%%%%%%%%     LOAD THE DATA    %%%%%%%%%%%%

pos = load_linear_position(baseDir);
laps = lapify_position(pos);

input.et = load_epoch_times(baseDir);

amp = load_dataset_features(baseDir, nChan);

input.data = amp;             % <- Feature decoding all spikes

input.nSpike = sum( cellfun(@(x)(size(x,1)), input.data) );

input.resp_col = 1:nChan;

input.method = 'Simulated On-line';

%%%%%%%%%%%%%% Construct the Inputs for the Decoder %%%%%%%%%%%%%%

isMovingIdx = abs(pos.lv) > minVelocity;

stimTimestamp = pos.ts(isMovingIdx);
stimulus = pos.lp(isMovingIdx);
stimulus = stimulus(:);

badIdx = isnan( stimulus );
stimulus = stimulus(~badIdx);
stimTimestamp = stimTimestamp(~badIdx);

tbins = input.et(1) : decodeDT : input.et(2)-decodeDT;
tbins = tbins( tbins >= stimTimestamp(1) & tbins <=stimTimestamp(end)-decodeDT);
tbins = [tbins', tbins'+decodeDT]; 

% remove tbins when the animal isn't moving
isMovingIdx = logical( interp1(pos.ts, double(isMovingIdx), mean(tbins,2), 'nearest') );

tbins = tbins(isMovingIdx, :);

 
posGrid = min(pos.lp):decodeDP:max(pos.lp);


P = [];
clear E;
nLap = size(laps,1);

% Start with LAP 2 b/c there is not information prior to LAP 1
for iLap = 2:nLap
    lapStart = laps(iLap,1);
    lapEnd = laps(iLap,2);
    
    % Use timebins PRIOR to current lap start as encoding segments
    encSeg = tbins( tbins(:,2) < lapStart , :);
    
    % Use timbins in the CURRENT lap for decoding segments
    decSeg = tbins( tbins(:,1) >= lapStart & tbins(:,2) < lapEnd , :);
   
    fprintf('Decoding Lap:%d of %d\n', iLap, nLap);
    
    clear z; % clear any previously existing decoder from memory
    
    d = input.data;
    st = {}; % Spike Timestamp
    sp = {}; % Spike Position
    sf = {}; % Spike Features
    
    % Structure inputs for the KDE_Decoder object
    emptyIdx = false(numel(d),1);
    for jj = 1:numel(d)
        if numel( d{jj} ) == 0
            emptyIdx(jj) = true;
            continue;
        end
        
        st{jj} = d{jj}(:, nChan+1); % Spike Times
        sp{jj} = d{jj}(:, nChan+2); % Spike Position
        sf{jj} = d{jj}(:, input.resp_col); % Spike Features
        
        emptyIdx(jj) = nnz( inseg( encSeg, st{jj} ) ) < 1 || nnz( inseg( decSeg, st{jj} ) ) < 1;
        
    end
    
    % remove spike groups without any spikes
    st = st(~emptyIdx); 
    sp = sp(~emptyIdx);
    sf = sf(~emptyIdx);    

    % SKIP LAPS WITHOUT ANY SPIKES
    if isempty(st) || isempty(sp) || isempty(sf)
        continue;
    end
    
    % construct the decoder
    z = kde_decoder(stimTimestamp, stimulus, st, sp, sf, ...
        'encoding_segments', encSeg, ...
        'stimulus_variable_type', 'linear', ...
        'stimulus_grid', {posGrid}, ...
        'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', stimulusBandwidth, ...
        'response_variable_type', 'linear', ...
        'response_kernel', 'gaussian', ...
        'response_bandwidth', responseBandwidth );
   
    [P{iLap}, E(iLap)] = z.compute(decSeg);
end