function newS = gh_bridge_segs(s, max_gap, varargin)

% 1     2          3    4   5        6
% /  \  /  \       / \  / \ / \      /   \
% 1     1          3    3   3        6
% 1                2                 3   <-- rename

p = inputParser();
p.addParamValue('draw',false);
p.parse(varargin{:});

nOldSeg = numel(s);

if(nOldSeg < 2)
    newS = s;
    return;
end

nNewS = 0;
lastEndT = -Inf;

newSTag = ones(nOldSeg,1);

for n = 1:nOldSeg
    if(s{n}(1) > lastEndT + max_gap)
        newSTag(n) = nNewS + 1;
        nNewS = nNewS + 1;
    else
        newSTag(n) = nNewS;
    end
    lastEndT = s{n}(2);
end

newS = cell(nNewS,1);

for n = 1:nNewS
    thisSegs = s( newSTag == n );
    newS{n} = [thisSegs{1}(1), thisSegs{end}(2)];
end

if(p.Results.draw)
    gh_draw_segs({s,newS})
end

% 
% % Initialize index for segment to be kept, and list of 'keep?'s
% acc_seg = 1;
% keep_seg = ones(size(s));
% 
% % Cycle through all segments
% for n = 2:nOldSeg
%     if (s{n}(1) - s{acc_seg}(2)  <= max_gap)
%         % Move the end of acc_seg to the end of this seg, delete this seg
%         s{acc_seg}(2) = s{n}(2);
%         keep_seg(n) = false;
%     else
%         % This seg becomes the acc_seg
%         acc_seg = n;
%     end
% end
% 
% new_s = s(logical(keep_seg));
