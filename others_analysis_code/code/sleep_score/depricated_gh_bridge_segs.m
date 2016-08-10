function new_s = gh_bridge_segs(s, max_gap)

% 1     2          3    4   5        6
% /  \  /  \       / \  / \ / \      /   \
% 1     1          3    3   3        6
% 1                2                 3   <-- rename


n_segs = numel(s);

if(n_segs < 2)
    new_s = s;
    return;
end

% Initialize index for segment to be kept, and list of 'keep?'s
acc_seg = 1;
keep_seg = ones(size(s));

% Cycle through all segments
for n = 2:n_segs
    if (s{n}(1) - s{acc_seg}(2)  <= max_gap)
        % Move the end of acc_seg to the end of this seg, delete this seg
        s{acc_seg}(2) = s{n}(2);
        keep_seg(n) = false;
    else
        % This seg becomes the acc_seg
        acc_seg = n;
    end
end

new_s = s(logical(keep_seg));
