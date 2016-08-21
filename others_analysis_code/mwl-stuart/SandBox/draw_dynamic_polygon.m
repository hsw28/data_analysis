function nodes =  draw_dynamic_polygon(varargin)

a = axescheck(varargin{:});
if isempty(a)
    hFig = figure;
    figure(hFig);
    a = axes;
else
    hFig = get(a, 'Parent');
end

old_motionfcn = get(hFig,'WindowButtonMotionFcn'); %#ok
old_keypressfcn = get(hFig,'KeyPressFcn'); %#ok
old_downfcn = get( hFig, 'WindowButtonDownFcn'); %#ok

%nodes = zeros(0,2);
nodes = [];
%nnodes = 0;
node_move_selected = false;
cur_point=0;
dist = 5;

%mode = 1; % 1 = Draw points, 2 = Delete Points, 3 Connect points

l_node = line(nan, nan, 'LineStyle', '--', 'Marker', '.', ...
    'MarkerSize', 30, 'MarkerEdgeColor', 'k', 'color', 'k', 'LineWidth',2 );
l_sel_m = line(NaN, NaN, 'LineStyle', 'none', 'Marker', '.',...
                'MarkerSize', 50, 'MarkerEdgeColor', 'r');
l_close = line(nan, nan, 'LineStyle', '--', 'Marker', '.', ...
    'MarkerSize', 30, 'MarkerEdgeColor', 'k', 'color', 'k', 'LineWidth',2 );

set(hFig,'WindowButtonMotionFcn', @move_mouse );
set(hFig,'WindowButtonDownFcn', @btndown);
set(hFig,'KeyPressFcn', @keypress);

waitfor(a,'UserData',1)

     
    function close_polygon()
        x = get(l_node,'XData'); 
        y = get(l_node,'YData');      
        if numel(x)>2
            set(l_close, 'XData', x([1,end]), 'YData', y([1,end]));
        else
            set(l_close, 'XData', nan, 'YData', nan);
        end
    end
        
        
    function draw_sel_node_move(cp)        
        set(l_sel_m, 'XData', nan, 'YData', nan);
        set(l_sel_m, 'XData', cp(1), 'YData', cp(2))
        close_polygon();
    end           

    function btndown(src, event) %#ok
        cp = get(a, 'CurrentPoint');
        cp = cp(1,1:2)';
        seltype = get(src, 'SelectionType');
        switch seltype
            case 'normal' %left click
                left_click(cp);
            case 'extend' %middle click
                middle_click(cp);
            case 'alt' %right click
                right_click(cp);
        end
    end

    function left_click(cp)
        %disp('Left Click')
        if node_move_selected % if we are already moving a node
            node_move_selected = false;
            cur_point = 0;
            set(l_sel_m, 'XData', nan, 'YData', nan);
                   
        else % otherwise we are creating a node or looking to click one
            nodes = [get(l_node,'XData'); get(l_node,'YData')];
            cur_point = is_current_point(cp, nodes, dist);
            switch cur_point>0
                case 0
                    nodes = [nodes, cp];
                    if isnan(nodes(1,1))
                        nodes = nodes(:,2:end);
                    end
                    set(l_node, 'XData', nodes(1,:), 'YData', nodes(2,:))
                case 1
                    %disp(['Found node:', num2str(cur_point)]);
                    node_move_selected = true;
            end               
        end
        close_polygon;
    end

    function middle_click(cp) %use middle click to end
        disp('Left click for more points, right click to close');
    end
    function right_click(cp)
        set(a,'UserData', 1);        
    end    

    function move_mouse(src, event) %#ok
        if node_move_selected
            cp = get(a, 'CurrentPoint');
            cp = cp(1,1:2)';
            nodes = [get(l_node,'XData'); get(l_node,'YData')];
            nodes(:,cur_point) = cp;
            set(l_node, 'XData', nodes(1,:), 'YData', nodes(2,:))
            draw_sel_node_move(cp);
        end
    end  

    function keypress(src, event) %#ok
    end
        
end


function ind = is_current_point(cp, nodes, max_d)
    ind =0;
    if size(nodes,1)
       for i=1:size(nodes,2)
          dist = sqrt( ...
              (nodes(1,i) - cp(1)).^2 + ...
              (nodes(2,i) - cp(2)).^2 );
         % disp(['Dist:', num2str(dist), ' ind:', num2str(i)]);
          if dist<max_d
              ind = i;
              return
          end
       end
    end
end



