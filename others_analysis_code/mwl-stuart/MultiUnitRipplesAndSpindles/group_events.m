function [startIdx, setLen, setId] = group_events(ts, win)

% initialIdx contains the indicies of the first event in a SET
% setLen indicates how long each set is
% setIdx identifies which set each event is in

if ~isvector(ts)
    error('Specified timestamps must be a vector');
end
if ~numel(win)==2
    error('Window must be 1x2');
end

if size(ts,2)>size(ts,1)
    ts = ts';
end

isi = [win(1); diff(ts)];

startIdx = nan(size(isi));
setLen = nan(size(isi));
setId = nan(size(isi));

setCount = 0;
for j = 1:numel(isi)
    
    if isi(j) >= win(1) % if enough time has passed to create a new set
        
        setCount = setCount+1;
        
        startIdx(j) = j;
        setId(j) = setCount;
        
        len = find( isi(j+1 : end) > win(2),1,'first');
        
        if isempty(len)
            setLen(j) = 1;
        else
            setLen(j) = len;
        end
    end
end

startIdx = startIdx(isfinite(startIdx));
setLen = setLen(isfinite(setLen));
