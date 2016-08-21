function draw_bounding_boxes(b, startY, height, spacing, min, max, c, ax)
   
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
        bursts = b{i};
        bursts = bursts(bursts(:,1) > min & bursts(:,2) < max , :);
        seg_plot(bursts, 'YOffset', curHeight, 'Height', height,...
            'FaceColor', c(i,:), 'Alpha', 1, 'Axis', ax);
        %         
%         for j = 1:size(bursts,1)
%             e = b{i}(j,:); % get an event
%             
%                 plot_rect(e, [curHeight, curHeight+height], c, 1, ax);            
%             
%         end
        curHeight = curHeight + spacing;
    end

end