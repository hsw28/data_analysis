function [samps, ts] = timeAverage(sigTs, signal, tbinEdges)

samps = nan(numel(tbinEdges)-1, 1);
for i = 1:numel(tbinEdges)-1
    win = tbinEdges([i, i+1]);
    idx = sigTs >= win(1) & sigTs<win(2);
    samps(i) = mean(signal(idx)); 
end

ts = tbinEdges(1:end-1);
    
    
