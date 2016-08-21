function [st] = calc_bilateral_replay_corr(d, PLOT, N_SHUFFLE)
%%

if nargin==1
    PLOT = 0;
end

if nargin<3
    N_SHUFFLE = 250;
end

if isfield(d.description, 'isexp') && d.description.isexp==1
    dPBin = .1;
else
    dPBin = .05;
end

lIdx = strcmp({d.clusters.hemisphere}, 'left');
rIdx = strcmp({d.clusters.hemisphere}, 'right');

args =  {'time_win', d.epochTime, 'tau', .02};
recon(1) = dset_reconstruct(d.clusters(lIdx), args{:} );
recon(2) = dset_reconstruct(d.clusters(rIdx), args{:} );    

isSpiking1 = sum(recon(1).spike_counts)>0;
isSpiking2 = sum(recon(2).spike_counts)>0;

p1 = recon(1).pdf;
p2 = recon(2).pdf;

N = round( .3 / dPBin );
% 

pSm1 = smoothn(p1, [N/2, 0]);
pSm2 = smoothn(p2, [N/2, 0]);

% pSm1 = p1;
% pSm2 = p2;

%%
% construct the replay events
b = d.mu.bursts;
nBurst = size(b,1);
eventLen =zeros(nBurst,1);

if max(eventLen) > 100
    error;
end

eventCorr = nan(nBurst, 1);

minLen = 4;
maxLen = 11;

for i = 1:nBurst
    
    idx = recon(1).tbins >= b(i,1) & recon(1).tbins <= b(i,2);
    
    eventLen(i) = nnz(idx);
        
    e1(i).pdf = pSm1(:, idx);
    e2(i).pdf = pSm2(:, idx);
    
    e1(i).spikes = isSpiking1(idx);
    e2(i).spikes = isSpiking2(idx);
    
    compIdx = e1(i).spikes & e2(i).spikes;
    eventCorr(i) = mean( corr_col( e1(i).pdf( :, compIdx ), e2(i).pdf( :, compIdx ) ) );
    
end

%%
nEvent = size(e1,2);
 
eventShufCorr = nan(N_SHUFFLE, nEvent);


% for each event compute the mean correlation with bilateral events of the
% same length 

for i = 1:nBurst
    lenIdx = find( eventLen == eventLen(i) );
    
    if numel( lenIdx ) < 10
        continue;
    end
    
    shufIdx = randsample( lenIdx, N_SHUFFLE, 1 );
    
    for j = 1:N_SHUFFLE
      
        jj = shufIdx(j);
        
        compIdx = e1(i).spikes & e2(jj).spikes;

        eventShufCorr(j, i) = mean( corr_col( e1(i).pdf(:, compIdx), e2(jj).pdf(:, compIdx) ) );
    end
end
%%
q = [.1 .25 .33 .5 .66 .75 .9];
st.quantiles = q;
st.realCorrQuantiles = quantile( eventCorr, q);
st.shufCorrQuantiles = quantile( eventShufCorr(:), q);
[~, st.pVal] = kstest2( eventCorr, eventShufCorr(:), .05, 'smaller');

st.eventCorrVals = eventCorr;
st.eventCorrValsShuf = eventShufCorr;
 
if PLOT
    [F1, X1] = ksdensity( eventCorr, 'support', [-1 1] );
    [F2, X2] = ksdensity( eventShufCorr(:), 'support', [-1 1] );

    f = figure;
    ax = axes;

    line(X1, F1, 'color', 'r'); hold on;
    line(X2, F2);
    xlabel('Correlation');
    ylabel('Probability');
    
    title(sprintf('kstest: %3.5g', st.pVal));
    
    figName = sprintf('fig5-eventCorr-%s-%d-%d', d.description.animal, d.description.day, d.description.epoch);
    save_bilat_figure(figName, f, 1);
end
%%


end
