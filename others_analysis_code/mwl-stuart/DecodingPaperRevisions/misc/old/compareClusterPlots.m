function compareClusterPlots(baseDir, iTetrode)
%%

   

    selClId = [];

    [cl, data, ttList] = load_clusters_for_day(baseDir);
    

    nTT = numel(cl);

    if nTT < iTetrode
        xc = [];
        fprintf('Invalid tetrode specified!');
        return;
    end

    amp = data{iTetrode}';
    clustId = cl{iTetrode};

    clear data;

    xcFile = sprintf('%s/kKlust/xcorr_%s.mat', baseDir, ttList{iTetrode});

    if ~exist(xcFile,'file')
        fprintf('%s file does not exist, creating it\n', xcFile)
        computeClusterXCorr(baseDir, iTetrode);
    end

    d = load(xcFile);
    xc = d.xc;


    clear d;

    if isempty(xc)
        fprintf('Fewer than 2 clusters, skipping\n');
        return;
    end



    nLag = size(xc,2);
    nCl = sqrt( size(xc,1) );
    xc = reshape(xc, [nCl, nCl, nLag] );


    stats = computeClusterStats(baseDir, iTetrode);

    maxLRatio = .05;
    idx = find( [stats.lRatio] <= maxLRatio );

    xc = xc( idx, idx, :);


    stats.nSpike = stats.nSpike(idx);
    stats.lRatio = stats.lRatio(idx);

    nCl = size(xc,1);
    xc = reshape(xc, [nCl * nCl, nLag] );
    nAx = nCl * nCl;

    % idx =  ismember(clustId, find(idx) ) ;
    % clustId = clustId(idx);
    % ampCl = amp(:, idx);

    fprintf('Plotting the correlations\n');
  
   % Render the xcorrs
    figure('Name', sprintf('%s - %s',baseDir, ttList{iTetrode}), 'Position', [0 300 900 800] );
    
    
    axH = tight_subplot(nCl, nCl, [.03 .02],[.05 .01],[.01 .01]);
    axCount = 0;

    x = [-50, linspace(-50, 50, size(xc,2)), 50];

    for iAx = 1 : nAx
         
        ii = ceil( iAx / nCl);
        jj = mod( iAx - 1,  nCl) + 1;

        axCount = axCount + 1;
        
        ax = axH(axCount);
        
         if jj < ii
             delete( ax );
         else

           
            y = squeeze( xc(axCount,:));
            y = [min([y, 0]), y, min([y, 0])];
            if any(isnan(y))
                continue;
            end

            patch(x, y, 'b', 'Parent', ax, 'hittest', 'off', 'EdgeColor', 'none')
            
            xlabel(ax, sprintf('%d x %d',idx(ii), idx(jj)));
            set(ax,'XTick', [-50 0 50],'YTick',[], 'XLim', [-50 50], 'YLim', minmax(y));

            set(ax,'UserData', [idx(ii), idx(jj), ii, jj]);
            
            set(ax, 'ButtonDownFcn', @axesSelected)

  
         end
        % end
    end

    ch = [1; 2; 3; 4];

    % Setup the graphical objects
    ampAx = axes('Position', [.05 .05 .425 .425 ], 'color','k'); 
    uicontrol('Parent', gcf, 'Style', 'pushbutton', 'Units','normal','position', [.050, .475, .1, .025], 'Callback', @prevProj, 'string', '<---');
    uicontrol('Parent', gcf, 'Style', 'pushbutton', 'Units','normal','position', [.375, .475, .1, .025], 'Callback', @nextProj, 'string', '--->');
    initializeTable();

    corrAx = axes('Position', [.5 .05 .3 .165], 'YTick', []);

    % Plot the lines for the clusters
    l(1) = line(0, 0, 0, 'Parent', ampAx);
    l(2) = line(0, 0, 0, 'Parent', ampAx);
    l(3) = line(0, 0, 0, 'Parent', ampAx);
    
    set(l, 'linestyle', 'none', 'marker', '.');
    set(l(1), 'MarkerSize', 1, 'color','w');
    set(l(2), 'Color', 'c');
    set(l(3), 'Color', 'y');

    set(ampAx,'XTick', [], 'YTick', []);
    % leg = legend(l(2:3), {' ', ' '}, 'Location', 'northwest');

    % Initialize the figure logic
    drawAllPoints();

    function drawAllPoints()
        set(l(1), 'XData', amp(ch(1),:), 'YData', amp(ch(2),:), 'ZData', amp(ch(3),:));
        drawClusterPoints();
    end

    function drawClusterPoints()
        
        if isempty(selClId)
            return;
        end
       
        fprintf('Plotting %d %d %d %d\n', selClId);
        idx1 = clustId == selClId(1);
        idx2 = clustId == selClId(2);


        set( l(2), 'XData', amp(ch(1),idx1), 'YData', amp(ch(2),idx1), 'ZData', amp(ch(3),idx1) );
        set( l(3), 'XData', amp(ch(1),idx2), 'YData', amp(ch(2),idx2), 'ZData', amp(ch(3),idx2) );
         % set( l(3), 'XData', amp(ch(1),idx1), 'YData', amp(ch(2),idx1), 'ZData', amp(ch(3),idx1) );


        title(ampAx, sprintf('Cyan-%d Yellow-%d', selClId(1), selClId(2)) );

    end

    function drawCorrelation()


        if isempty(selClId)
            return;
        end

        iAx = (selClId(3)-1) * nCl + selClId(4);    
        y = squeeze( xc(iAx, :));
        y = [min([y, 0]), y, min([y, 0])];
        
        if any(isnan(y))
            return;
        end

        delete(get(corrAx,'Children'));
        patch(x, y, 'b', 'Parent', corrAx, 'hittest', 'off', 'EdgeColor', 'none');
        line(x, y*0, 'color', 'k', 'linewidth', 2, 'parent', corrAx);
        set(corrAx, 'YLim', minmax(y));
    end
            
    function axesSelected(src, e)
        
        selClId = get(src, 'UserData');
        % fprintf('Selecting clusters %d %d\n', selClId1, selClId2);

        drawClusterPoints();
        drawCorrelation();
    end

    function nextProj(varargin)
        ch = circshift(ch, 1);
        drawAllPoints();
    end

    function prevProj(varargin)
        ch = circshift(ch,-1);
        drawAllPoints();
    end

    function initializeTable()

        tbl = uitable('Parent', gcf,'Units', 'normal', 'Position', [.05 .52 .15 .28], 'rowname', [], 'CellSelectionCallback', @tableCallbackFcn  );

        names = {'Cl', 'nSpk', 'lRat'};

        data = [ idx, stats.nSpike, stats.lRatio * 100];

        set(tbl, 'ColumnName', names, 'Data',data , 'ColumnWidth', {25, 40, 60},...
         'columnformat', {'numeric', 'numeric', 'bank'}, 'columneditable', [false false false]);

    end

    function tableCallbackFcn(src, e)


        id2= e.Indices(1);
        id = idx(id2);
        
        selClId = [ id id id2 id2];

        drawClusterPoints();
        drawCorrelation();
    end
   
end %function


