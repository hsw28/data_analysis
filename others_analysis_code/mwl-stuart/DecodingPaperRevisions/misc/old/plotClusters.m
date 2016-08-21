function plotClusters(baseDir)

[cl, data, ttList] = load_clusters_for_day(baseDir);
nTT = numel(cl);

for iTetrode = 1:nTT

        clId = cl{iTetrode};
        nCl = max(clId);
        
        amp = data{iTetrode};

        figure('Name', sprintf('%s - %s', baseDir, ttList{iTetrode}), 'Position', [70 675 560 420] + iTetrode * [30 -30 0 0 ]);    
        axes('Color', 'k');
        cmap = colormap('jet'); 
        c = interp1(1:size(cmap,1), cmap, linspace(1, size(cmap,1), nCl), 'nearest');
        
        for iCluster = 1:nCl
            idx = clId == iCluster;

            line(amp(idx,1), amp(idx,2), amp(idx,3),'color', c(iCluster,:), 'marker', '.', 'linestyle', 'none', 'markersize', 1);        

        end
        
        pause(.01);
 end


end