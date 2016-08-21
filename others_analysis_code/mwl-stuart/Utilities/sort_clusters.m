function order = sort_clusters(clusters, field_num)
%   cluster_order = SORT_CLUSTERS(clusters)
%   returns the ordered indecies of the clusters.
%   ordered by place field peak
%

    switch field_num
        case 0
            f = 'tc0';
        case 1
            f = 'tc1';
        case 2
            f = 'tc2';
        otherwise
            f = 'tc1';
    end

peak_inds = nan(size(clusters));

for i = 1:length(clusters)
   [val peak_inds(i)] = max(clusters(i).(f));
end

[val order] = sort(peak_inds);
end