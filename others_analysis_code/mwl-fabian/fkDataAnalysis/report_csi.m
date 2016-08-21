function report_csi( clusters, varargin )



ncl = numel(clusters);

%sort on tetrodes and cluster_id
[sorted_clusters, si] = sortrows( [clusters.tetrode; clusters.cluster_id]', [1 2] );

%find max spike amplitudes
maxchan = [clusters.maxchan];
amp = {};
lbl = {};
for k=1:ncl
    amp{k} = clusters(k).amplitude(:, maxchan(k));
    lbl{k} = ['TT' num2str( clusters(k).tetrode, '%2d' ) '-' num2str( clusters(k).cluster_id, '%2d' ) ' ' num2str(k, '%2d')];
end

h = plot_csi( {clusters(si).timestamp}, amp(si), [0.003 0.015], varargin{:} );

set(h, 'YTickLabel', lbl(si), 'TickDir', 'out');

%draw lines between tetrodes
i = find( diff( sorted_clusters(:,1)' ) );
n = numel(i);

line( [i ; i] + 0.5, [ zeros(1,n) ; ncl*ones(1,n) ] + 0.5 , 'Color', [0 0 0]);
line( [ zeros(1,n) ; ncl*ones(1,n) ] + 0.5 , [i ; i] + 0.5, 'Color', [0 0 0] );

set(h, 'TickLength', [0.005 0.005] );