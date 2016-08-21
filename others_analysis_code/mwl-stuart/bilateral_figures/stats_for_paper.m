


%% Bilateral Run Decoding

clear;

eList = dset_list_epochs('Run');
nEpoch = size(eList, 1);

[pReal, pShuf, mCorr, mCorrS] = deal( nan(10, 1) );

parfor i = 1:nEpoch
    
    fprintf('\n');
    d = dset_load_all(eList{i,:});

    [pReal(i), pShuf(i), mCorr(i), mCorrS(i)] =...
        calc_bilateral_run_decoding_stats_single(d);
end
%%

[~, pVal_confMat] = ttest2(pReal, pShuf, .05, 'right');
[~, pVal_colCorr] = ttest2(mCorr, mCorrS, .05, 'right');
% pVal_confMat == 4.0529e-9   - Jan 31, 2013
% pVal_colCorr == 2.4993e-12   - Jan 31, 2013

%% Bilateral Replay Decoding

clear;
ep = 'sleep';
eList = dset_list_epochs(ep);
nEpoch = size(eList,1);

stats = struct('quantiles', [], 'realCorrQuantiles', [], 'shufCorrQuantiles', [], 'pVal', [], 'eventCorrVals', [], 'eventCorrValsShuf', []);
stats = repmat(stats, 10, 1);

parfor i = 1:nEpoch
    
    d = dset_load_all( eList{i,:} );
    
    stats(i) = calc_bilateral_replay_corr(d, 1);
   
end
pSleep = [stats.pVal];

ep = 'run';
eList = dset_list_epochs(ep);
nEpoch = size(eList,1);

stats = struct('quantiles', [], 'realCorrQuantiles', [], 'shufCorrQuantiles', [], 'pVal', [], 'eventCorrVals', [], 'eventCorrValsShuf', []);
stats = repmat(stats, 10, 1);

parfor i = 1:nEpoch
    
    d = dset_load_all( eList{i,:} );
    
    stats(i) = calc_bilateral_replay_corr(d, 1);
   
end

pRun = [stats.pVal];

%%
clear;
ep = 'run';

eList = dset_list_epochs(ep);
nEpoch = size(eList,1);

[cHigh, cLow] = deal( nan(nEpoch, 1) );
stats = repmat( struct('colCorr', [], 'burstRate', {{}}, 'burstCorr', []), 10, 1);

parfor i = 1:nEpoch
    %%
    d = dset_load_all( eList{i,:} );
    
    lIdx = strcmp({d.clusters.hemisphere}, 'left');
    rIdx = strcmp({d.clusters.hemisphere}, 'right');
    
 
    args = {'time_win', d.epochTime, 'tau', .02};
    
    recon1 = dset_reconstruct(d.clusters(lIdx), args{:} );
    recon2 = dset_reconstruct(d.clusters(rIdx), args{:} );
    
    [cHigh(i), cLow(i), stats(i)] = dset_compare_bilateral_pdf_by_n_mu_spike(d, recon1, recon2);
    
end

%pVal = signrank(cHigh, cLow, 'tail', 'right');
%pVal_Run   = 0.024
%pVal_Sleep = 0.024



%%

%Bilateral Ripple Freq Dist, r Squared

%      RUN     SLEEP
%IPSI  0.17     0.51
%
%CONT  0.17     0.29

% pval
%      RUN     SLEEP
%IPSI  1.8e-21 8.5e-18
%
%CONT  1.7e-146 0


