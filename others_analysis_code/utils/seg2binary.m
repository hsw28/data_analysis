function v = seg2binary(seg, ts)

segLen = diff(seg,[],2);

badSeg = segLen == 0;
seg = seg(~badSeg,:);

ts = (ts(:))';
v = 0 * ts;
seg = interp1(ts, 1:numel(ts), seg,'nearest');


v( seg(:,1) ) = 1;
v( seg(:,2) ) = -1;

v = cumsum(v)~=0;

% segFilt = segmentfilter(seg);
% 
% inSegTs = segFilt(ts);
% 
% inSegIdx = interp1(ts, 1:numel(ts), inSegTs, 'nearest');
% 
% idx = false(size(ts));
% idx(inSegIdx) = true;  



end