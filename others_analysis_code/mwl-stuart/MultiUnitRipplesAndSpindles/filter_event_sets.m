function [longSet, shortSet, setLen] = filter_event_sets(ts, N, win)

if ~isvector(ts)
    error('Specified timestamps must be a vector');
end
if ~isscalar(N)
    error('Burst Length must be a scalar');
end
if ~numel(win)==3
    error('Window must be 1x3');
end

if size(ts,2)>size(ts,1)
    ts = ts';
end

isi = [nan; diff(ts)];

longSet = nan(size(isi));
shortSet = nan(size(isi));
setLen = nan(size(isi));
N = N-1;

for j = 1:numel(isi) - N
    if  isi(j) > win(1)
        
        
        if all( isi(j+1 : j+N) < win(2) )
        
            longSet(j) = j;
            
            len = find( isi(j+1 : end) > win(2), 1, 'first' );
            
            if isempty(len)
                len = numel(isi) - j;
            end
            
            setLen(j) = len;
            
        elseif isi(j+1) > win(3)
         
            shortSet(j) = j;
        
        end
    end    
end

shortSet = shortSet(isfinite(shortSet));
longSet = longSet(isfinite(longSet));
setLen = setLen(isfinite(setLen));
