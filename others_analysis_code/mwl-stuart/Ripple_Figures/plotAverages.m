function [l, f, ax] = plotAverages(varargin)
    
    cols = 'rbgkcm';
    tmpFun = @(x) ([nanmin(x), nanmean(x), nanmax(x)]);

    nVar = numel(varargin);

    if mod(numel(varargin), 2) ~= 0
        error('Invalid number of inputs'); 
    end
    
    f = figure; 
    ax = axes;
    
    xRange = [inf, -inf];
    
    count = 0;
    
    l = [];
    for i = 1:2:nVar
        
        x = varargin{i};
        y = varargin{i+1};
        yRange = minmax(y);
        
        y = y - min(y);
        y = y ./ max(y);
        
        y = y .* .9;
        y = y + .05;
        
        
        c =  cols( ceil(i/2) );
        l(end+1) = line(x,y, 'color', c );
        
        xRange(1) = min(xRange(1), min(x));
        xRange(2) = max(xRange(2), max(x));
        
        
    end
    
    set(ax,'Xlim', xRange, 'YTick', [], 'YColor', 'w');
    
    for i = 1:2:nVar
        c =  cols( ceil(i/2) );

        count = count + 1;
        
        X = xRange(1) + .05 * (i-1);%quantile(x, .0 + .1 * (count-1) );
        
        dx = diff(xRange) / 100; %(x, .01 + .1 * (count-1) ) - X;
       
        line( X * [1 1], [.05 .95], 'color', c, 'linestyle', '--');
        
        yTick = linspace(.05, .95, 3);
        
        
        
        yVal = tmpFun(varargin{i+1});
        
        for j = 1:3
            line( X + [0 dx], yTick(j) * [1 1 ], 'color', c);
            text(X + 2 * dx, yTick(j), sprintf('%2.1f', round(yVal(j)*100)/100), 'fontsize', 16, 'color', c);
        end
        
    end
    
    line([0 0], [0 1], 'color', 'k', 'linestyle', '--');
   

end