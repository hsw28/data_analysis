function k = fieldAsymmetry(clust, xsUnfolded,rateUnfolded)

nBins      = numel(xsUnfolded);
lastBinInd = floor(nBins/2);
dx         = xsUnfolded(2) - xsUnfolded(1);
lastOutX   = xsUnfolded(lastBinInd);
xsFolded = [xsUnfolded(1:lastBinInd), xsUnfolded(lastBinInd:-1:1)];

fieldXs  = xsUnfolded(rateUnfolded > 0);
fieldXsF = xsFolded(rateUnfolded > 0);
fieldExtent = [min(fieldXsF),max(fieldXsF)];

if(all(fieldXs <= lastOutX + dx))
    fieldName = 'out_pos_at_spike';
    coef = 1;
elseif(all(fieldXs >= lastOutX - dx))
    fieldName = 'in_pos_at_spike';
    coef = -1;
else
    fieldXs
    k = NaN;
    return;
    error('fieldAsymmetry:straddlingField',...
          'Field seems to straddle outbound/inbound boundary');
end
posInd = find(strcmp(fieldName,clust.featurenames),1,'first');
spikePos = clust.data(:,posInd);
spikePos = spikePos(~isnan(spikePos));
spikePos = spikePos(spikePos >= min(fieldExtent) & ...
                    spikePos <= max(fieldExtent));

spikePosMean = mean(spikePos);
spikePosStd  = std(spikePos);

spikePosThirdMoment = mean( (spikePos - spikePosMean).^3 );

k = coef * spikePosThirdMoment / (spikePosStd ^3);

%peakInd = find(rateUnfolded == max(rateUnfolded), 1, 'first');

%k = (xsUnfolded(peakInd) - min(fieldXs)) / (max(fieldXs) - min(fieldXs));



%wid = max(fieldXs) - min(fieldXs);

%k(wid < 0.6) = 0;

%fieldMid = mean(fieldXs);

%frontActivity = sum(rateUnfolded(xsUnfolded > fieldMid));
%backActivity = sum(rateUnfolded(xsUnfolded < fieldMid));

%k = frontActivity / (frontActivity + backActivity);