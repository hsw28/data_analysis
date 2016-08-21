
function [P, E, input] = decode_feature_vs_cluster(baseDir, nChan)
%% Load DATA

if ~exist(baseDir,'dir');
    error('Invalid directory specified');
end

if ~isscalar(nChan) || ~isnumeric(nChan) || ~ismember(1, [1, 4])
    error('nChan must be a numeric scalar equal to 1 or 4');
end

input.description = baseDir;
input.methods = nChan;

%%%%%%%%%%%% DECODING PARAMETERS %%%%%%%%%%%%
pcaMaxLR = Inf;    % used to ignore clusters with poor lratio
decodeDT = .25;     % time bin width for decoder
decodeDP = .1;      % position bin width for decoding
minVelocity = .15;  % minimun velocity for spikes to be used for encoding
stimulusBandwidth = .1; 
responseBandwidth = 30;
timeSplit = 0; % 0 -> 1st vs 2nd half, 1 -> Every other bin

%%%%%%%%%%%%     LOAD THE DATA    %%%%%%%%%%%%

pos = load_linear_position(baseDir);

input.et = load_epoch_times(baseDir);

clId = load_dataset_clusters(baseDir, 'pca', nChan);

[amp, pc] = load_dataset_features(baseDir, nChan);

clStats = compute_cluster_stats(clId, pc);  % <- Not used


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   SETUP INPUTS FOR THE DECODER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Group Spikes by cluster
cl = {}; 
for iTT = 1:numel(clId)    
    
    nullIdx = true( size(clId{iTT}) );
    
    for iCl = 1:max(clId{iTT})

        if clStats(iTT).lRatio(iCl) <= pcaMaxLR
            
            clIdx = iCl == clId{iTT};
            cl{end+1} = amp{iTT}( clIdx, : ); %#ok

            nullIdx(clIdx) = false;
        end
    end
    
    if nnz(nullIdx)>0
        cl{end+1} = amp{iTT}( nullIdx,:); %#ok
    end
end

input.data{1} = amp;             % <- Feature decoding all spikes
input.data{2} = cl;       % <- Cluster decoding PCA4 Sorted + Hash

input.nSpike = cellfun(@sum, cellfun( @(x) (cellfun(@(y)(size(y,1)), x)), input.data,'uniformoutput', 0));

input.resp_col{1} = 1:nChan;
input.resp_col{2} = []; % For identity decoding don't use any features

input.method{1} = 'Feature';
input.method{2} = 'Identity';


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

% create the position grid
posGrid = min(pos.lp):decodeDP:max(pos.lp);

encodingSegments = [];
decodingSegments = [];

switch timeSplit
    case 0 % 1st vs 2nd half
        
        n = size(tbins,1);
        splitIdx = ceil(n/2);
        
        encodingSegments = tbins(1:splitIdx,:);
        decodingSegments = tbins(splitIdx:end,:);

    case 1 % every other timebin
        n = numel(tbins);
        encodingSegments = tbins( 1:2:n, : );
        decodingSegments = tbins( 2:2:n, : );
        
    otherwise
        error('Invalid timeSplit, must by 0 or 1');
end

input.encoding_segments = encodingSegments;
input.decoding_segments = decodingSegments;
%% - Decode the position estimate

P = {};
clear E;

for ii = 1:numel(input.data)
   
    fprintf('Decoding %s --- %s\n', baseDir, input.method{ii});
    
    clear z; % clear any previously existing decoder from memory
    
    d = input.data{ii};
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
        sf{jj} = d{jj}(:, input.resp_col{ii}); % Spike Features
        
        emptyIdx(jj) = nnz( inseg( encodingSegments, st{jj} ) ) < 1 || nnz( inseg( decodingSegments, st{jj} ) ) < 1;
        
    end
    
    % remove spike groups without any spikes
    st = st(~emptyIdx); 
    sp = sp(~emptyIdx);
    sf = sf(~emptyIdx);    
    
    % construct the decoder
    z = kde_decoder(stimTimestamp, stimulus, st, sp, sf, ...
        'encoding_segments', encodingSegments, ...
        'stimulus_variable_type', 'linear', ...
        'stimulus_grid', {posGrid}, ...
        'stimulus_kernel', 'gaussian', ...
        'stimulus_bandwidth', stimulusBandwidth, ...
        'response_variable_type', 'linear', ...
        'response_kernel', 'gaussian', ...
        'response_bandwidth', responseBandwidth );
    
    
    [P{ii}, E(ii)] = z.compute(decodingSegments);
end
