function [counts centers] = psth(events, triggers, bwidth, nlags)

bins = -(nlags*bwidth):bwidth:((nlags+1)*bwidth);
nbins = numel(bins);
counts = zeros(numel(triggers), nbins);
for i=1:numel(triggers)
    counts(i,:) =  histc(events, triggers(i)+bins);
end

counts = counts(:,[1:nbins-1]);
centers = bins(1:end-1)+mean(diff(bins));
end