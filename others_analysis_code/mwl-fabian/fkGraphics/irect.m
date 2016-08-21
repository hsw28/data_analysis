function hRect = irect(position, varargin)
%IRECT draw an editable rectangle
%
%  h=IRECT(position) draws a rectangle defined by the position vector
%  ([left bottom width height]) and allows the user to interactively change
%  the circle. The function returns a handle to the rectangle. Get(h,'rect')
%  will return a structure with rectangle data. Dragging the sides aor
%  corners will change the size of the rectangle, dragging the center
%  point, will move the rectangle.
%
%  h=IRECT(...,parm1,val1,...) passes in extra parameter/value pairs. Valid
%  parameters are:
%   axes - handle of parent axes
%   need_selection - rectangle can be edited only when it is selected
%   selected - 0/1 selected state of rectangle
%

%check input arguments
if nargin<1
  help(mfilename)
  return
end

options = struct( 'axes', [], 'need_selection', 0, 'selected', 0);
options = parseArgs( varargin, options );

if isempty( options.axes )
  options.axes = gca;
end

axes(options.axes);
hFig = gcf;

%create rectangle
hRect = rectangle('Position', position );
hCorners = line( position(1)+[0 0 position(3) position(3)], position(2) + [0 position(4) position(4) 0], 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', [0 0 1]);
hCenter = line( position(1)+0.5*position(3), position(2)+0.5*position(4), 'Marker', 'o', 'MarkerFaceColor', [0 0 1]);

set( hCenter, 'ButtonDownFcn', @startdrag_center );
set( hRect, 'ButtonDownFcn', @startdrag_outline );
set( hCorners, 'ButtonDownFcn', @startdrag_corners );

set( hRect, 'DeleteFcn', @delfcn)

    function delfcn(hObj,eventdata)
        delete(hCorners(ishandle(hCorners)));
        delete(hCenter(ishandle(hCenter)));
    end

    function startdrag_center(hObj, eventdata)
        if strcmp(get(hRect,'Selected'),'off') && options.need_selection
            return
        end
  
        set( hFig, 'WindowButtonMotionFcn', @drag_center);
        set( hFig, 'WindowButtonUpFcn', @stopdrag );
  
    end

    function startdrag_corners(hObj, eventdata)
        if strcmp(get(hRect,'Selected'),'off') && options.need_selection
            return
        end
        
        %determine which corner is selected
        corner = 0;
        cp = get(options.axes, 'CurrentPoint');
        pos = get(hRect,'Position');
        corner = bitset(corner, 1, cp(1,1)>(pos(1)+0.5*pos(3)) );
        corner = bitset(corner, 2, cp(1,2)>(pos(2)+0.5*pos(4)) );
        
        set( hFig, 'WindowButtonMotionFcn', {@drag_corners, corner});
        set( hFig, 'WindowButtonUpFcn', @stopdrag )        
    end

    function startdrag_outline(hObj, eventdata)
        if strcmp(get(hRect,'Selected'),'off') && options.need_selection
            return
        end
        
        %determine which side is selected
        side = 0;
        cp = get(options.axes, 'CurrentPoint');
        pos = get(hRect,'Position');
        fcn = @(x) pos(2)+((x-pos(1)).*pos(4))./pos(3);
        side = bitset(side, 1, cp(1,2)>fcn(cp(1,1)));
        fcn = @(x) pos(2)+pos(4)+((x-pos(1)).*-pos(4))./pos(3);        
        side = bitset(side, 2, cp(1,2)>fcn(cp(1,1)));
        
        set( hFig, 'WindowButtonMotionFcn', {@drag_outline, side});
        set( hFig, 'WindowButtonUpFcn', @stopdrag )        
    end

    function drag_center(hObj,eventdata)
        cp = get(options.axes, 'CurrentPoint');
        pos = get(hRect,'Position');
        pos = pos + [cp(1,1)-pos(1)-0.5*pos(3) cp(1,2)-pos(2)-0.5*pos(4) 0 0];
        set(hRect, 'Position', pos );
        set(hCenter, 'XData', pos(1)+0.5*pos(3), 'YData', pos(2)+0.5*pos(4));
        set(hCorners, 'XData', pos(1)+[0 0 pos(3) pos(3)], 'YData', pos(2) + [0 pos(4) pos(4) 0]);
    end

    function drag_corners(hObj, eventdata, corner)
        cp = get(options.axes, 'CurrentPoint');
        pos = get(hRect,'Position');
        ll = pos([1 2]);
        ur = pos([1 2])+pos([3 4]);
        switch corner
            case 0 % lower left
                ll = cp(1,[1 2]);
                ll(1) = min(ll(1), ur(1));
                ll(2) = min(ll(2), ur(2));
            case 1 % lower right
                ll(2) = min(cp(1,2), ur(2));
                ur(1) = max(cp(1,1), ll(1));
            case 2 % upper left
                ll(1) = min(cp(1,1), ur(1));
                ur(2) = max(cp(1,2), ll(2));
            case 3 % upper right
                ur = cp(1,[1 2]);
                ur(1) = max(ur(1), ll(1));
                ur(2) = max(ur(2), ll(2));
        end
        pos = [ll ur-ll];
        pos([3 4]) = max( pos([3 4]), eps );
        set(hRect, 'Position', pos);
        set(hCenter, 'XData', pos(1)+0.5*pos(3), 'YData', pos(2)+0.5*pos(4));
        set(hCorners, 'XData', pos(1)+[0 0 pos(3) pos(3)], 'YData', pos(2) + [0 pos(4) pos(4) 0]);
        
    end

    function drag_outline(hObj, eventdata, side)
        
        cp = get(options.axes, 'CurrentPoint');
        pos = get(hRect,'Position');
        ll = pos([1 2]);
        ur = pos([1 2])+pos([3 4]);
        switch side
            case 0 % bottom
                ll(2) = min(cp(1,2), ur(2) );
            case 1 % left
                ll(1) = min(cp(1,1), ur(1));
            case 2 % right
                ur(1) = max(cp(1,1), ll(1));
            case 3 % top
                ur(2) = max(cp(1,2), ll(2));
        end
        pos = [ll ur-ll];
        pos([3 4]) = max( pos([3 4]), eps );
        set(hRect, 'Position', pos);
        set(hCenter, 'XData', pos(1)+0.5*pos(3), 'YData', pos(2)+0.5*pos(4));
        set(hCorners, 'XData', pos(1)+[0 0 pos(3) pos(3)], 'YData', pos(2) + [0 pos(4) pos(4) 0]);
        
    end

    function stopdrag(hObj, eventdata) %#ok
        set( hFig, 'WindowButtonMotionFcn', [] );
        set( hFig, 'WindowButtonUpFcn', [] );
    end


end
