function s = gh_split_segs_at_trough(d, oldS, trough_value, anticmp, antiextreme,minDTSamps,minPeak)

toSplit = cellfun(@(x) needsSplit(d,x, trough_value,anticmp, antiextreme,minDTSamps,minPeak), oldS);
splitInds = cmap(@(x) splitInd(d,x, anticmp, antiextreme,minDTSamps), oldS(toSplit));

segSecondHalfs = cellfun(@(x,i) [i,x(2)], oldS(toSplit), splitInds,'UniformOutput',false);
segFirstHalfs  = cellfun(@(x,i) [x(1),i], oldS(toSplit), splitInds,'UniformOutput',false);

oldS(toSplit) = segFirstHalfs;
s = [oldS; segSecondHalfs];

s = sortBy(@(x) x(1), s);

end

function b = needsSplit(d, seg, trough_value, anticmp, antiextreme,minDTSamps,minPeak)
xR = possibleTroughRange(d, seg, anticmp,minDTSamps) + seg(1);
if(isempty(xR))
    b = false;
    return
end
b = anticmp(antiextreme(d(xR(1):xR(2))), trough_value) && ...
    anticmp(minPeak, d(xR(1))) && anticmp(minPeak, d(xR(2)));
end

function i = splitInd(d, seg, anticmp, antiextreme,minDTSamps)
xR = possibleTroughRange(d, seg, anticmp,minDTSamps) + seg(1);
thisD = d(xR(1):xR(2));
i = find(thisD == antiextreme(thisD), 1, 'first') + xR(1);
end

function xRange = possibleTroughRange(d,seg, anticmp,minDTSamps)
thisD = d(seg(1):seg(2));
isLocalExtreme = anticmp( thisD(3:end), thisD(2:(end-1)) ) & ...
    anticmp( thisD(1:(end-2)), thisD(2:(end-1)) );
if(sum(isLocalExtreme) < 2)
xRange = [];
return
else
xRange = [ find(isLocalExtreme,1,'first'), find(isLocalExtreme,1,'last') ];
if(diff(xRange) < minDTSamps)
    xRange = [];
end
end
end

%
%possiblySplit p f (x:xs)
% | p (x)  ->  fst (f x) : snd (f x) : possiblySplit p f xs
% | otherwise -> x : possiblySplit p f xs