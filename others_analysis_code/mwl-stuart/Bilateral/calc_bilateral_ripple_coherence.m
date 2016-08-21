function [results] = calc_bilateral_ripple_coherence(ripples)


% Prepare the data for analysis
nAnimal = numel(ripples);
nRipple = sum( arrayfun(@(x) size(x.raw{1},1), ripples, 'UniformOutput', 1) );
nSample = size(ripples(1).window,2);

% allocate our variables
[ripBase, ripIpsi, ripCont, ripShuf1]  = deal( zeros(nRipple, nSample) );

% Create the REAL data set
idx = 1;
for i = 1:nAnimal;
    n = size(ripples(i).raw{1}, 1);  % number of ripples for this animal
    ripBase( idx : idx+n - 1 , :) = ripples(i).raw{1};
    ripIpsi( idx : idx+n - 1 , :) = ripples(i).raw{2};
    ripCont( idx : idx+n - 1 , :) = ripples(i).raw{3};
    idx = idx + n; 
end

% Create WITHIN animal SHUFFLE data
idx = 1;
for i = 1:nAnimal
    n = size(ripples(i).raw{1}, 1); % number of ripples for this animal
    
    ripShuf1( idx : idx+n-1 , :) = ripples(i).raw{2}(randsample(n,n,1),:);
    ripShuf2( idx : idx+n-1 , :) = ripples(i).raw{3}(randsample(n,n,1),:);

    idx = idx + n; 
end

clearvars idx n nSampPerRipple shuffleIndex i
%%
%Check to see if a matlab pool is already open
if matlabpool('size')<1
    matlabpool('open');
else
    sprintf('Matlab pool is already open with size:%d\n', matlabpool('size'));
end

%winIdx = 1 : 601; 
winIdx = 100:300;

% Setup arguments  for MSCOHERE
nWindow = 6;
perOverlap  = 0;
nSamp = numel(winIdx);
nfft = 2 ^ nextpow2( nSamp );
winLen = round( nSamp / nWindow);
noverlap = round( winLen * perOverlap);

fs = ripples(1).Fs;

coherenceArgs = {[],[],[],fs};
%coherenceArgs = {winLen, noverlap, nfft, fs};
% compute the Frequency vector was we can't save it in a parfor loop
%[~, F] = mscohere(ripBase(1,winIdx), ripCont(1,winIdx),[], noverlap, nfft, fs);

[coTemp, F] = mscohere(ripBase(1,winIdx), ripCont(1,winIdx),coherenceArgs{:});
[cohereIpsi, cohereCont, shuffleIpsi, shuffleCont] =  deal( zeros(nRipple, size(coTemp,1) ) );

% Calculate the Correlations

disp('Computing ripple coherence, this might take a while! Go get some water!');
tic;
parfor i = 1:nRipple
%     rippleCoherence(i,:)   = mscohere(ripBase(i,winIdx), ripCont(i,winIdx),[], noverlap, nfft, fs);
%     shuffleCoherence1(i,:) = mscohere(ripBase(i,winIdx), ripShuf1(i,winIdx),[], noverlap, nfft, fs);
%     shuffleCoherence2(i,:) = mscohere(ripBase(i,winIdx), ripShuf2(i,winIdx),[], noverlap, nfft, fs);
    cohereCont(i,:)   = mscohere(ripBase(i,winIdx), ripCont(i,winIdx), coherenceArgs{:});
    cohereIpsi(i,:)   = mscohere(ripBase(i,winIdx), ripIpsi(i,winIdx), coherenceArgs{:});
    shuffleIpsi(i,:) = mscohere(ripBase(i,winIdx), ripShuf1(i,winIdx), coherenceArgs{:});
    shuffleCont(i,:) = mscohere(ripBase(i,winIdx), ripShuf2(i,winIdx), coherenceArgs{:});
end
dt = toc;
fprintf('Done! That took %4.4f seconds!\n', dt);
% 
% results.rippleCoherence{1} = cohereIpsi;
% results.rippleCoherence{2} = cohereCont;
% results.shuffleCoherence{1} = shuffleIpsi;
% results.shuffleCoherence{2} = shuffleCont;

results.cohereIpsi = cohereIpsi;
results.cohereCont = cohereCont;
results.shuffleIpsi = shuffleIpsi;
results.shuffleCont = shuffleCont;

results.F = F;
results.shuffleType = {'ipsilateral', 'contralateral'};

end



%% - Plot the results
















