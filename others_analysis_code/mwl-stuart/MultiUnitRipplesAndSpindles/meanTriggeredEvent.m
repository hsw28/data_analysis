function [meanCount, ts, counts] = ...
    meanTriggeredEvent(triggerTimes, eventTimes, tbins)

if ~isvector(eventTimes) || isscalar(eventTimes)
    error('Event times must be a vector');
end 
if ~isvector(triggerTimes) || isscalar(triggerTimes)
    error('Trigger times cannot be a matrix');
end

if ~isvector(tbins) || isscalar(tbins)
    error('tbins must be a vector');
end

if numel(tbins)==2
    tbins = linspace(tbins(1), tbins(2), 10);
end

timestampCheck(tbins);
Fs = 1 / ( tbins(2) - tbins(1) );

triggerTimes = (triggerTimes(:))';
eventTimes = eventTimes(:);

eventTrigTimeDiff = bsxfun(@minus, eventTimes,triggerTimes);


tbins = [tbins, tbins(end)+tbins(2)-tbins(1)];

counts = histc(eventTrigTimeDiff, tbins)';
counts = counts(:,1:end-1);
counts = counts  * Fs;
ts = tbins(1:end-1);

meanCount = mean(counts);







end