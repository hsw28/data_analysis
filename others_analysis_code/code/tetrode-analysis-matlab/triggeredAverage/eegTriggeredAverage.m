function trigCdat = eegTriggeredAverage(inCdat, trigTimes, timeWin)

trigCdat = inCdat;


trigOkWindow = [inCdat.tstart - timeWin(1), inCdat.tend - timeWin(2)];
trigTimes = trigTimes( trigTimes >= trigOkWindow(1) & trigTimes <= trigOkWindow(2) );

inCdat.data( isnan(inCdat.data) ) = 0;

nChan = size(inCdat.data,2);
nSamp = size(inCdat.data,1);

inTS = conttimestamp(inCdat);
dt = 1/inCdat.samplerate;

trigTS = (timeWin(1):dt:timeWin(2))';
nNewSamp = numel(trigTS);

trigCdat.data = zeros(nNewSamp,nChan);
trigCdat.variance = trigCdat.data;

trigTimes = reshape(trigTimes,1,[]);

trigInterpTimes = bsxfun(@plus, trigTS, trigTimes);

for c = 1:nChan
    chanData = inCdat.data(:,c);
    alignedData = interp1(inTS, chanData', trigInterpTimes,'linear','extrap');
    trigCdat.data(:,c) = mean(alignedData,2);
    trigCdat.variance(:,c) = std(alignedData,[],2).^2;
    trigCdat.n = size(alignedData,2);
end



trigCdat.tstart = trigTS(1);
trigCdat.tend   = trigTS(end);