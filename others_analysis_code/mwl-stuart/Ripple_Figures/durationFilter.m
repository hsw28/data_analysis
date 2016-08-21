function e = durationFilter(e, dur)

eDur = diff(e,[],2);

if numel(dur)==1
    idx = eDur >= dur(1);
elseif numel(dur)==2
    idx = eDur >= dur(1) & eDur <= dur(2);
else
    error('Invalid duration filter');
end

e = e(idx,:);

end