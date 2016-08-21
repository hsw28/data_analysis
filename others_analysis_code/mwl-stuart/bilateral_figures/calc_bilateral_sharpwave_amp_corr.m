clear;
dset = dset_load_all('spl11', 'day12', 'sleep2');
d = dset_calc_ripple_params(dset);
%%

r = d.ripples;
nRipple = numel(r.peakIdx);
ts = r.window / r.fs;

SHOW_PLOT = 1;
if SHOW_PLOT
    close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral Ripple Instaneous Frequency Correlations vs Shuffles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ripWin = [-.01 .01];
ripIdx = ts >= ripWin(1) & ts<=ripWin(2);

trig.instFreq = r.instFreq{1}(:, ripIdx);
ipsi.instFreq = r.instFreq{2}(:, ripIdx);
cont.instFreq = r.instFreq{3}(:, ripIdx);

corrIdx = ~isnan(trig.instFreq .* ipsi.instFreq .* cont.instFreq);

[freqCorr.ipsi, freqCorr.pIpsi]= corr(trig.instFreq(corrIdx(:)), ipsi.instFreq(corrIdx(:)));
[freqCorr.cont, freqCorr.pCont]= corr(trig.instFreq(corrIdx(:)), cont.instFreq(corrIdx(:)));

nShuffle = 1000;
for iShuffle = 1:nShuffle

   randIdx = randsample(nRipple, nRipple,1); 
   
   ipsiShuffle = ipsi.instFreq(randIdx,:);
   contShuffle = cont.instFreq(randIdx,:);
   
   corrIdx = ~isnan(trig.instFreq .* ipsiShuffle .*contShuffle);
   
   freqCorr.ipsiShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), ipsiShuffle(corrIdx(:)) );
   freqCorr.contShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), contShuffle(corrIdx(:)) );
   
end

freqCorr.ipsiPvalMC = max( sum( freqCorr.ipsiShuff > freqCorr.ipsi) / nShuffle, 1/nShuffle);
freqCorr.contPvalMC = max( sum( freqCorr.contShuff > freqCorr.cont) / nShuffle, 1/nShuffle);

bins = -.4:.025:.4;


if SHOW_PLOT
    
    figure('Position', [200 550 560 420]);
    subplot(211);
    hist(freqCorr.ipsiShuff, bins); 
    line(freqCorr.ipsi * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Ipsilateral Ripple Freq Corr: P<= %2.3f', freqCorr.ipsiPvalMC));

    subplot(212);
    hist(freqCorr.contShuff, bins); 
    line(freqCorr.cont * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Contralateral Ripple Freq Corr: P<= %2.3f', freqCorr.contPvalMC));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral SW Peak Amplitude Correlations vs Shuffles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


swWin = [-.05 .05];
swIdx = ts >= swWin(1) & ts<=swWin(2);

% correct sharpwaves
sw = {};
swBaseline = {};
for i = 1:3
    sw{i} = abs(r.sw{i});
    sw{i} = bsxfun(@minus, sw{i}, mean(sw{i}(:, 1:5),2) );
    sw{i} = bsxfun(@rdivide, sw{i}, max( mean(sw{i})) );
end

[trig.swPeakAmp, ipsi.swPeakAmp, cont.swPeakAmp] = deal( zeros(nRipple, 1) );

for iRipple = 1:nRipple

    trig.swPeakAmp(iRipple) = max( sw{1}(iRipple,swIdx) );
    ipsi.swPeakAmp(iRipple) = max( sw{2}(iRipple,swIdx) );
    cont.swPeakAmp(iRipple) = max( sw{3}(iRipple,swIdx) );
   
end
    
ampCorr.ipsi = corr(trig.swPeakAmp, ipsi.swPeakAmp);
ampCorr.cont = corr(trig.swPeakAmp, cont.swPeakAmp);

nShuffle = 1000;

for iShuffle = 1:nShuffle

   randIdx = randsample(nRipple, nRipple,1); 
   
   ipsiShuffle = ipsi.swPeakAmp(randIdx,:);
   contShuffle = cont.swPeakAmp(randIdx,:);
      
   ampCorr.ipsiShuff(iShuffle) = corr( trig.swPeakAmp, ipsiShuffle );
   ampCorr.contShuff(iShuffle) = corr( trig.swPeakAmp, contShuffle );
   
end

ampCorr.ipsiPvalMC = max( sum( ampCorr.ipsiShuff > ampCorr.ipsi) / nShuffle, 1/nShuffle);
ampCorr.contPvalMC = max( sum( ampCorr.contShuff > ampCorr.cont) / nShuffle, 1/nShuffle);
    
if SHOW_PLOT
    bins = -.4:.025:.4;
    figure('Position', [250 500 560 420]);
    subplot(211);
    hist(ampCorr.ipsiShuff, bins); 
    line(ampCorr.ipsi * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Ipsilateral SW Amplitude Corr: P<= %2.3f', ampCorr.ipsiPvalMC));

    subplot(212);
    hist(ampCorr.contShuff, bins); 
    line(ampCorr.cont * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Contralateral SW Amplitude Corr: P<= %2.3f', ampCorr.contPvalMC));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral SW Phase Ripple Envelope Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rEnv = {};
swPhase = {};
for i = 1:3
    rEnv{i} = abs(hilbert(r.rip{i}'))';
    swPhase{i} = angle(hilbert(r.sw{i}'))';
end

[~, mIdxIpsi] = max(rEnv{2}, [], 2);
[~, mIdxCont] = max(rEnv{2}, [], 2);

mIndIpsi= sub2ind( size(rEnv{1}), 1:nRipple, mIdxIpsi');
mIndCont= sub2ind( size(rEnv{1}), 1:nRipple, mIdxCont');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Bilateral Phase x Amplitude distribution vs shuffle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[mPhaseIpsi, mEnvIpsi] = circ_mean_vec(swPhase{1}(mIndIpsi), rEnv{2}(mIndIpsi));
[mPhaseCont, mEnvCont] = circ_mean_vec(swPhase{1}(mIndCont), rEnv{3}(mIndCont));

phaseEnv.corrIpsi = circ_corrcl(swPhase{1}(mIndIpsi), rEnv{2}(mIndIpsi));
phaseEnv.corrCont = circ_corrcl(swPhase{1}(mIndCont), rEnv{3}(mIndCont));

[mShuffPhaseIpsi, mShuffEnvIpsi, mShuffPhaseCont, mShuffEnvCont] = deal( zeros(nShuffle, 1));

for i = 1:nShuffle
    
    randIdx = randsample(nRipple, nRipple);
    swPhaseShuff = swPhase{1}(randIdx,:); 
    [mShuffPhaseIpsi(i), mShuffEnvIpsi(i)] = circ_mean_vec(swPhaseShuff(mIndIpsi), rEnv{2}(mIndIpsi));
    [mShuffPhaseCont(i), mShuffEnvCont(i)] = circ_mean_vec(swPhaseShuff(mIndCont), rEnv{3}(mIndCont));
    
    phaseEnv.ipsiShuff(i) = circ_corrcl( swPhaseShuff(mIndIpsi), rEnv{2}(mIndIpsi));
    phaseEnv.contShuff(i) = circ_corrcl( swPhaseShuff(mIndCont), rEnv{3}(mIndCont));
    
end



phaseEnv.ipsiPvalMC = max( sum( phaseEnv.ipsiShuff > phaseEnv.corrIpsi) / nShuffle, 1/nShuffle);
phaseEnv.contPvalMC = max( sum( phaseEnv.contShuff > phaseEnv.corrCont) / nShuffle, 1/nShuffle);


z = zeros(1,nRipple);

if SHOW_PLOT
    figure('Position', [300 450 560 420]);
    polar( [z; swPhaseShuff(mIndIpsi)], [z; rEnv{2}(mIndIpsi)], 'b'); hold on;
    polar( [z; swPhase{1}(mIndIpsi)], [z; rEnv{2}(mIndIpsi)],'r');
    polar( swPhaseShuff(mIndIpsi), rEnv{2}(mIndIpsi),'o');
    polar( swPhase{1}(mIndIpsi), rEnv{2}(mIndIpsi),'ro');
    title( 'Ipsilateral SW Phase RipEnv Distribution');

    figure('Position', [350 400 560 420]);
    polar( [z; swPhaseShuff(mIndCont)], [z; rEnv{3}(mIndCont)], 'b'); hold on;
    polar( [z; swPhase{1}(mIndCont)], [z; rEnv{3}(mIndCont)],'r');
    polar( swPhaseShuff(mIndCont), rEnv{3}(mIndCont),'o');
    polar( swPhase{1}(mIndCont), rEnv{3}(mIndCont),'ro');
    title( 'Contralateral SW Phase RipEnv Distribution');
end

fprintf('SW Phase Ripple Env Correlation - Ipsi:%2.4f Contra:%2.4f\n', [phaseEnv.corrIpsi phaseEnv.corrCont]);

z = zeros(nShuffle,1);

figure('Position', [400 350 560 420]);
polar( [0, mPhaseIpsi], [0, mEnvIpsi], 'r'); hold on;
polar( [z, mShuffPhaseIpsi]', [z, mShuffEnvIpsi]', 'b');
polar( [0, mPhaseIpsi], [0, mEnvIpsi], 'r');
title( 'Ipsilateral Mean Vector vs Shuffle');

figure('Position', [450 300 560 420]);
polar( [0, mPhaseCont], [0, mEnvCont], 'r'); hold on;
polar( [z, mShuffPhaseCont]', [z, mShuffEnvCont]', 'b');
polar( [0 ,mPhaseCont], [0, mEnvCont], 'r');
title( 'Contralateral Mean Vector vs Shuffle');


bins = -0:.01:.5;

if SHOW_PLOT
    figure('Position', [500 250 560 420]);
    subplot(211);
    hist(phaseEnv.ipsiShuff, bins); 
    line(phaseEnv.corrIpsi * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Ipsilateral SW Amplitude Corr: P<= %2.3f', phaseEnv.ipsiPvalMC));

    subplot(212);
    hist(phaseEnv.contShuff, bins); 
    line(phaseEnv.corrCont * [1 1], get(gca,'YLim'), 'Color', 'r', 'linewidth', 2);
    title(sprintf('Contralateral SW Amplitude Corr: P<= %2.3f', phaseEnv.contPvalMC));
end

%%



