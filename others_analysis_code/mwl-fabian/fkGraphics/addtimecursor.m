function h=addtimecursor(hAx)
%ADDTIMECURSOR

if nargin<1 || ~isscalar(hAx) || ~ishandle(hAx) || ~strcmp(get(hAx,'type'),'axes')
    error('addtimecursor:invalidHandle', 'Invalid axes handle')
end

h = findobj( hAx, 'tag', 'timecursor' );

if isempty(h)
    
    additime(hAx);
    
    hAx = handle(hAx);
    
    event_dispatch(ancestor(hAx,'figure'));

    h = patch( hAx.CurrentTime+[0 0], hAx.YLim, [0 0 0], 'Tag', 'timecursor', 'Parent', hAx, 'FaceColor', 'none', 'EdgeColor', [0 0 1], 'EdgeAlpha', 0.25, 'LineWidth', 2.5 );

    enable_events( h );
  
    add_callback( h, 'MyDragFcn', @dragcursorfcn );
    
    L = handle.listener( hAx, findprop(hAx,'YLim'), 'PropertyPostSet', {@changedYLim, h} );
    L(end+1) = handle.listener( hAx, findprop(hAx, 'CurrentTime'), 'PropertyPostSet', {@updatecursor, h});
    
    setappdata( h, 'timecursorlistener', L);
    
    % Define the context menu
    cmenu = uicontextmenu;
    item1 = uimenu(cmenu, 'Label', 'center', 'Callback', {@centercursor,hAx});
    set(h, 'UIContextMenu', cmenu);
    
end

function centercursor(hObj,eventdata,h)

set(h, 'CurrentTime', mean( get(h, 'XLim') ) );

function dragcursorfcn( hObj, eventdata )

x = eventdata.HitPoint(1);
set( hObj, 'XData', [x x] );
set( get(hObj,'Parent'), 'CurrentTime', x );

function updatecursor( hObj, eventdata, h)

hAx = eventdata.affectedObject;
set( h, 'XData', [0 0] + get(hAx, 'CurrentTime') );

function changedYLim( hObj, eventdata, h )

hAx = eventdata.affectedObject;
set(h, 'YData', get(hAx, 'YLim') );