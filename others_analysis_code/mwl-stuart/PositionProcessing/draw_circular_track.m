function [center radius] = draw_circular_track(varargin)%

center =[];
radius =[];
numel(varargin)
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

hCircle = nan;

set(hFig,'WindowButtonMotionFcn', @mouse_motion_fn );
set(hFig,'WindowButtonDownFcn', @moust_click_fn);

nodes = [];
nnodes=0;

set(hFig,'pointer', 'crosshair');

waitfor( ax, 'UserData', DONE);

set(hFig,'pointer', 'arrow');

if ishandle(hFig)
  set( hFig, 'WindowButtonMotionFcn', old_motionfcn );
  set( hFig, 'WindowButtonDownFcn', old_downfcn );
  set( hFig, 'KeyPressFcn', old_keypressfcn );
  
  if del_fig
    delete( hFig );
  end
  
end


    function mouse_motion_fn(hObj,eventdata) %#ok
        %drawnow;
        cp = get(ax, 'CurrentPoint');
        if nnodes>0 && nnodes<2
            x1 = nodes(1,1);
            y1 = nodes(1,2);
            x2 = cp(1,1);
            y2 = cp(1,2);
            center(1) = (x2+x1)/2;
            center(2) = (y2+y1)/2;
            radius = sqrt((x1-center(1))^2 + (y1-center(2))^2);
            if ~isnan(hCircle)
                delete(hCircle);
            end
            hCircle = circle(ax, center, radius);
            set(hCircle, 'linewidth', 3, 'edgecolor', 'g');
        end
    end
        function moust_click_fn(hObj,eventdata) %#ok
            
            seltype = get(hObj, 'SelectionType');
            cp = get(ax, 'CurrentPoint');
            cp = cp(1,1:2);
            
            switch seltype
                case 'normal' %left mouse click
                    if nnodes<2
                        nnodes = nnodes+1;
                        nodes(nnodes,:) = cp(1,1:2);
                        disp(nodes(nnodes,:));
                    end
                case 'extend' %middle mouse button
                    nnodes = 1;
                    nodes(nnodes,:) = cp(1,1:2);
                    
                case 'alt' %right mouse click
                    nnodes
                    if nnodes==2
                        set(ax, 'UserData', DONE);
                    end
            end
            
        end
        
    end
