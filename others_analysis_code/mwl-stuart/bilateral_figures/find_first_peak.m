function peakTs = find_first_peak(startTs, peakTs)

curIdx = 0;

idx = nan .* startTs;

for i = 1:numel(startTs)
    curIdx = find( peakTs >= startTs(i), 1, 'first');
    idx(i) = curIdx;

end

peakTs = peakTs(idx);