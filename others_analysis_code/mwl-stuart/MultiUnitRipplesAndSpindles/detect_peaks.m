function [peakTs] = detect_peaks(ts, x, win)

if nargin > 2
    if ~isempty(win) && numel(win)==2 && ismonotonic(win)
        idx = ts> win(1) & ts<=win(2);
        x = x(idx);
        ts = ts(idx);
    else
        error('Invalid window specified!');
    end
end


[~, pkIdx] = findpeaks(x, 'MINPEAKDISTANCE', 3);
peakTs = ts(pkIdx);

end