function [nodes, connect] =  draw_dynamic_nodes(varargin)

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
connect = zeros(0,2);
%nnodes = 0;
MAX_CON = 100;
nconnect = 0;
node_move_selected = false;
node_connect_selected = false;
cur_point=0;
dist = 5;

%mode = 1; % 1 = Draw points, 2 = Delete Points, 3 Connect points

l_node = line(nan, nan, 'LineStyle', 'none', 'Marker', '.', ...
    'MarkerSize', 30, 'MarkerEdgeColor', 'r');
l_con = nan(MAX_CON,1);
l_sel_m = line(NaN, NaN, 'LineStyle', 'none', 'Marker', '.',...
                'MarkerSize', 40, 'MarkerEdgeColor', 'g');

l_sel_c =  line(nan, nan, 'LineStyle', 'none', 'Marker', '.', ...
    'MarkerSize', 40, 'MarkerEdgeColor', 'c');

addlistener(l_node, 'XData', 'PostSet', @draw_connections);
addlistener(l_node, 'YData', 'PostSet', @draw_connections);


set(hFig,'WindowButtonMotionFcn', @move_mouse );
set(hFig,'WindowButtonDownFcn', @btndown);
set(hFig,'KeyPressFcn', @keypress);

waitfor(a,'UserData',1)

    function draw_connections(src, event) %#ok
        if nconnect>0
           x = get(l_node,'XData');
           y = get(l_node,'YData');
            if size(x)==size(y) %when new points are added the xdata listener fires before the ydata gets added so I have to add this check first so the draw_connections doesn't throw an error
               nodes = [x; y];
                for i=1:nconnect
                    if isnan(l_con(i))
                        l_con(i) = line(nan, nan, 'Color', 'k', 'LineWidth', 3);
                    end
                    set(l_con(i), 'XData', [nodes(1, connect(i,1)) nodes(1, connect(i,2))] , ...
                                       'YData', [nodes(2, connect(i,1)) nodes(2, connect(i,2))] )
                end
            end
        end
    end
   
    function draw_sel_node_move(cp)        
        set(l_sel_m, 'XData', nan, 'YData', nan);
        set(l_sel_m, 'XData', cp(1), 'YData', cp(2))
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
        
        elseif node_connect_selected % if we are already connecting a node
            
        else % otherwise we are creating a node or looking to click one
            nodes = [get(l_node,'XData'); get(l_node,'YData')];
            cur_point = is_current_point(cp, nodes, 2.5);
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
        draw_connections()
    end

    function middle_click(cp) %use middle click to end
        %disp('Middle Click')
        set(a,'UserData', 1)
        %{
        if node_move_selected
           left_click
           return
        end
        nodes = [get(l_node,'XData'); get(l_node,'YData')];
        nnodes = size(nodes,2);
        cur_point = is_current_point(cp, nodes, dist);
        if cur_point
            nodes = nodes(:,[1:cur_point-1, cur_point+1:nnodes]);
            set(l_node, 'XData', nodes(1,:), 'YData', nodes(2,:))            
        end
        %}
        
    end
    function right_click(cp)
        %disp('Right Click')
        nodes = [get(l_node,'XData'); get(l_node,'YData')];
        if node_move_selected % already moving a node?
            left_click
        elseif node_connect_selected % already have a node for a connection?
            cur_point2 = is_current_point(cp, nodes, dist);
            if cur_point2
                nconnect = nconnect+1;
                connect(nconnect,:) = [cur_point cur_point2]; 
                node_connect_selected = false;
                cur_point = 0;
                set(l_sel_c, 'XData', nan, 'YData', nan);
                draw_connections()
            end
        else 
            cur_point = is_current_point(cp, nodes, dist);
            node_connect_selected =  cur_point>0;
            if node_connect_selected
                set(l_sel_c, 'XData', nodes(1,cur_point), 'YData', nodes(2,cur_point));
            end
        end
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



