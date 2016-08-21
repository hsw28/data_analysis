function draw_bounding_edges(b, startY, height, spacing, min, max, c, ax)
   
    if ~iscell(b)
        b = {b};
    end
    
    if nargin<2 || isempty(startY)
        startY = 0;
    end
    
    if nargin<3 || isempty(height)
        height = 1;
    end
    
    if nargin<4 || isempty(spacing)
        spacing = 0;
    end
    
    if nargin<5 || isempty(min)
        min = -Inf;
    end
    
    if nargin<6 || isempty(max)
        max = Inf;
    end
    
    if nargin<7 || isempty(c)
        c = 'k';
    end
    
    if nargin<8 || isempty(ax)
        ax = axes();
    end
    
    curHeight = startY;
    
    for i = 1:numel(b)
        for j = 1:size(b{i},1)
            e = b{i}(j,:); % get an event
            if e(1)>min || e(2) < max 
                plot_rect_edges(e, [curHeight, curHeight+height], c, 2, ax);            
            end
        end
        curHeight = curHeight + spacing;
    end

end