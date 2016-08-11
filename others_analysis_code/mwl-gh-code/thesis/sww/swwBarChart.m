function f = swwBarChart(r)

    means  = cellfun(@mean,r);
    n      = cellfun(@numel,r);
    stds   = cellfun(@std,r);
    sterrs = real(stds ./ sqrt(n-1));
    
    [XX,OF] = meshgrid( [1:size(r,2)], [1:size(r,1)]);
    nSeries = size(means,2);
    nLevels = size(means,1);
    
    doVert = true;
    if doVert
        f = bar(means);
        ylim([0.001,10]);
        set(gca,'XTick', 1:5);
        set(gca,'XTickLabels',{'Sleep','Drowsy','Run','Pause','Pause (Night)'});
        set(gca,'YScale','log');
    else
        f = barh(means);
        set(gca,'YDir','reverse');
        set(gca,'YTick', 1:5);
        set(gca,'YTickLabels',{'Sleep','Drowsy','Run','Pause','Pause (Night)'});
        xlim([0,1]);
    end
    set(gcf,'Color',[1,1,1]);
    hold on;   
    arrayfun(@(h,e,i,j) drawError(h,e,nSeries,nLevels,i,j,doVert),...
        means,sterrs,XX,OF);

end

function drawError(h,e,m,n,i,j,doV)

    barToBarWidth = 1/(m+1.5);
    x = j + ((i) - (n-1)/2)*barToBarWidth;
    serif_xs = barToBarWidth*[-0.3,0.3] + x;
    stem_xs  = repmat(mean(serif_xs,2),1,2);
    
    serif_top_ys = repmat(h+e,1,2);
    serif_bot_ys = repmat(h-e,1,2);
    stem_ys      = [serif_top_ys(1),serif_bot_ys(1)];

    if(doV)
        plot(serif_xs, serif_top_ys, 'k');
        plot(serif_xs, serif_bot_ys, 'k');
        plot(stem_xs,  stem_ys     , 'k'); 
    else
        plot(serif_top_ys,serif_xs, 'k');
        plot(serif_bot_ys,serif_xs, 'k');
        plot(stem_ys,     stem_xs,  'k');
    end
        
end