function [x_tl y_tl, x_br, y_br] = draw_dynamic_rectangle(varargin)%

x_tl = [];
x_br = [];
y_tl = [];
y_br = [];
delete_when_finished = 1;


if numel(varargin)==1
    ax = varargin{1};
    del_fig = 0;
else
    ax = axes;
    del_fig = 1;
end

DONE = 1;
NOT_DONE = 0;

set(ax,'UserData', NOT_DONE);

hFig = gcf;

old_motionfcn = get(hFig,'WindowButtonMotionFcn');
old_keypressfcn = get(hFig,'KeyPressFcn');
old_downfcn = get( hFig, 'WindowButtonDownFcn');

hLine = nan;

set(hFig,'WindowButtonMotionFcn', @mouse_motion_fn );
set(hFig,'WindowButtonDownFcn', @mouse_click_fn);

nodes = [];
nnodes=0;

set(hFig,'pointer', 'crosshair');

waitfor(ax, 'UserData', DONE);

set(hFig,'pointer', 'arrow');

delete(hLine);

if ishandle(hFig)
  set( hFig, 'WindowButtonMotionFcn', old_motionfcn );
  set( hFig, 'WindowButtonDownFcn', old_downfcn );
  set( hFig, 'KeyPressFcn', old_keypressfcn );
  
  if del_fig
    delete( hFig );
  end
  
end
% line([x x x+dx x+dx x], [y y+dy y+dy y y]

    function mouse_motion_fn(hObj,eventdata) %#ok
        %drawnow;
        cp = get(ax, 'CurrentPoint');
        if nnodes>0 && nnodes<2
            x_tl = nodes(1,1);
            y_tl = nodes(1,2);
            x_br = cp(1,1);
            y_br = cp(1,2);
            dx = x_br - x_tl;
            dy = y_br - y_tl;
            
            x_vec = [x_tl, x_tl, x_tl+dx, x_tl + dx, x_tl];
            y_vec = [y_tl, y_tl+dy, y_tl+dy, y_tl, y_tl];
                
            if ~isnan(hLine)
                delete(hLine);
            end
            hLine = line(x_vec, y_vec, 'LineStyle', '--', 'Color', 'k','LineWidth',2 ,'Parent', ax);   
        end
            
    end
        function mouse_click_fn(hObj,eventdata) %#ok
            
            seltype = get(hObj, 'SelectionType');
            cp = get(ax, 'CurrentPoint');
            cp = cp(1,1:2);
            
            switch seltype
                case 'normal' %left mouse click
                    if nnodes<2
                        nnodes = nnodes+1;
                        nodes(nnodes,:) = cp(1,1:2);
                        %disp(nodes(nnodes,:));
                    end
                case 'extend' %middle mouse button
                    nnodes = 1;
                    nodes(nnodes,:) = cp(1,1:2);
                    
                case 'alt' %right mouse click
                   
                    if nnodes==2
                        set(ax, 'UserData', DONE);
                    end
                    
            end 
        end
    end
