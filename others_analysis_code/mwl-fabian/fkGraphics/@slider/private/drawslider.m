function ui = drawslider( h, p)

%enable event dispatching
event_dispatch( ancestor( h, 'figure' ) );

%get container size in characters
old_units = get(h, 'Units');
set(h, 'Units', 'characters');
pos = get(h, 'Position');
set(h, 'Units', old_units);

label_width = min( 0.1*pos(3), 10 );
btn_width = min( 0.05.*pos(3), 4 );
edit_width = min( 0.1*pos(3), 10);
ax_width = pos(3) - 2*edit_width - 2*(label_width+btn_width);

edit_height = max( 1, pos(4)/2 );

xoffset = cumsum( [0 label_width btn_width ax_width btn_width label_width ...
                   edit_width edit_width]);

ui.ax = axes('Parent', h, ...
             'Units', 'characters', ...
             'Position', [xoffset(3) 0 ax_width pos(4)], ...
             'XTick', [], ...
             'YTick', [], ...
             'NextPlot', 'new');

ui.limedit(1) = uicontrol('Parent', h, ...
                          'Units', 'characters', ...
                          'Style', 'edit', ...
                          'Position', [xoffset(1) 0 label_width edit_height], ...
                          'String', num2str(p.limits(1)), ...
                          'Callback', @changemin, ...
                          'FontSize', 8);
ui.label(1) = uicontrol('Parent', h, ...
                        'Units', 'characters', ...
                        'Style', 'text', ...
                        'Position', [xoffset(1) edit_height label_width edit_height], ...
                        'String', 'min', ...
                        'FontSize', 8);

ui.button(1) = uicontrol('Parent', h, ...
                         'Units', 'characters', ...
                         'Position', [xoffset(2) 0 btn_width-1 pos(4)], ...
                         'String', '<', 'ButtonDownFcn', {@stepbtndown, -0.5}, ...
                         'Enable', 'inactive');

ui.button(2) = uicontrol('Parent', h, ...
                         'Units', 'characters', ...
                         'Position', [xoffset(4)+1 0 btn_width-1 pos(4)], ...
                         'String', '>', 'ButtonDownFcn', {@stepbtndown, 0.5}, ...
                         'Enable', 'inactive');

ui.limedit(2) = uicontrol('Parent', h, ...
                          'Units', 'characters', ...
                          'Style', 'edit', ...
                          'Position', [xoffset(5) 0 label_width edit_height], ...
                          'String', num2str(p.limits(2)), ...
                          'Callback', @changemax, ...
                          'FontSize', 8);
ui.label(2) = uicontrol('Parent', h, ...
                        'Units', 'characters', ...
                        'Style', 'text', ...
                        'Position', [xoffset(5) edit_height label_width edit_height], ...
                        'String', 'max', ...
                        'FontSize', 8);

ui.center_edit = uicontrol('Parent', h, ...
                           'Units', 'characters', ...
                           'Style', 'edit', ...
                           'Position', [xoffset(6) 0 edit_width edit_height], ...
                           'String', num2str( p.center ), ...
                           'Callback', {@changecenter}, ...
                           'FontSize', 8);
ui.label(3) = uicontrol('Parent', h, ...
                        'Units', 'characters', ...
                        'Style', 'text', ...
                        'Position', [xoffset(6) edit_height edit_width edit_height], ...
                        'String', 'center', ...
                        'FontSize', 8);

ui.edit = uicontrol('Parent', h, ...
                    'Units', 'characters', ...
                    'Style', 'edit', ...
                    'Position', [xoffset(7) 0 edit_width edit_height], ...
                    'String', num2str( p.windowsize ), ...
                    'Callback', {@changesize}, ...
                    'FontSize', 8);
ui.label(4) = uicontrol('Parent', h, ...
                        'Units', 'characters', ...
                        'Style', 'text', ...
                        'Position', [xoffset(7) edit_height edit_width edit_height], ...
                        'String', 'size', ...
                        'FontSize', 8);

set(ui.ax, 'XLim', p.limits, 'YLim', [0 1]);

set( [ui.limedit ui.label ui.button ui.edit ui.ax], 'Units', 'normalized');

ui.patch = patch( p.center + max( p.windowsize, 0.01.*diff(p.limits) ).* ...
                  [-0.5 0.5 0.5 -0.5], [0 0 1 1], p.color, 'EdgeColor', ...
                  p.color, 'Parent', ui.ax);
ui.text = text( p.center, 0.5, num2str(p.center),'Parent', ui.ax, 'Visible', ...
                'off', 'HorizontalAlignment', 'center' , 'VerticalAlignment', 'middle', 'Color', [0 0 0]);

ui.contextmenu = uicontextmenu('Parent', ancestor(h, 'figure') );

m = uimenu( ui.contextmenu, 'Label', 'Update Mode' );
ui.updatemenu(1) = uimenu( m, 'Label', 'delayed', 'Callback', {@setupdatemode, h, 'delayed'});
ui.updatemenu(2) = uimenu( m, 'Label', 'live', 'Callback', {@setupdatemode, h, 'live'});

ui.markermenu = uimenu( ui.contextmenu, 'Label', 'Marker' );
ui.markermenu_items(1) = uimenu( ui.markermenu, 'Label', 'none', 'Checked', ...
                                 'on', 'Callback', {@setmarker, h});

ui.addmarker = uimenu( ui.contextmenu, 'Label', 'Add/Remove Marker', 'Callback', ...
                       {@addmarker, h} );

m = uimenu( ui.contextmenu, 'Label', 'Segment Display Mode' );
ui.displaymenu(1) = uimenu( m, 'Label', 'strict', 'Callback', {@setdisplaymode, h, 'strict'});
ui.displaymenu(2) = uimenu( m, 'Label', '+50%', 'Callback', {@setdisplaymode, h, '+50%'});
ui.displaymenu(3) = uimenu( m, 'Label', 'window size', 'Callback', {@setdisplaymode, h, 'window size'});

if strcmp(p.updatemode, 'delayed')
  set(ui.updatemenu(1), 'Checked', 'on')
else
  set(ui.updatemenu(2), 'Checked', 'on')
end

if strcmp(p.displaymode, 'strict')
  set(ui.displaymenu(1), 'Checked', 'on')  
elseif strcmp(p.displaymode, '+50%')
  set(ui.displaymenu(2), 'Checked', 'on')  
else
  set(ui.displaymenu(3), 'Checked', 'on')
end


set([ui.ax ui.patch], 'UIContextMenu', ui.contextmenu);

enable_events([ui.ax ui.patch]);

set( ui.ax, 'MyButtonDownFcn', @axisdownfcn );
set( ui.ax, 'MyKeyPressFcn', @axiskeyfcn  );

set( ui.patch, 'MyStartDragFcn', @startthumbdragfcn );

set(h, 'ResizeFcn', @ResizeParent);

%==========================================================================
function retval = axiskeyfcn( hObj, eventdata )

retval = true;

switch eventdata.KeyCode
 case 37 %left
  stepbtndown(hObj, eventdata, -1);
 case 39 %right
  stepbtndown(hObj, eventdata, 1);
 case 38 %up
  hObj = get(hObj, 'Parent');
  s = getappdata(hObj, 'Slider');
  s.windowsize = s.windowsize*1.5;
  s.currentmarkerval = NaN;
  setappdata(hObj, 'Slider', s);
  set( s.ui.patch, 'XData', s.center + max( s.windowsize, ...
                                            0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
  set(s.ui.edit, 'String', num2str( s.windowsize ) );
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hObj, s.center, s.windowsize );
  fireUpdateEvent(slider(hObj));
 case 40 %down
  hObj = get(hObj, 'Parent');
  s = getappdata(hObj, 'Slider');
  s.windowsize = s.windowsize/1.5;
  s.currentmarkerval = NaN;
  setappdata(hObj, 'Slider', s);
  set( s.ui.patch, 'XData', s.center + max( s.windowsize, ...
                                            0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
  set(s.ui.edit, 'String', num2str( s.windowsize ) );
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hObj, s.center, s.windowsize );  
  fireUpdateEvent(slider(hObj));
 otherwise
  retval = false;
end

%==========================================================================


%==========================================================================
function retval = startthumbdragfcn( hObj, eventdata )
retval = false;

if all(eventdata.Button==1)
  
  hAx = get(hObj,'Parent');
  hP = get(hAx, 'Parent');
  s = getappdata(hP, 'Slider');
  
  set(s.ui.text, 'Visible', 'on', 'Position', [s.center 0.5 0], 'String', num2str(s.center));
  set( hObj, 'MyDragFcn', {@thumbdragfcn, eventdata.ClickedPoint(1)-s.center, ...
                   hAx} );
  set( hObj, 'MyStopDragFcn', @stopthumbdragfcn);
  retval = true;
  
elseif all(eventdata.Button==2)
  
  hAx = get(hObj,'Parent');
  hP = get(hAx, 'parent');
  s = getappdata(hP, 'Slider');
  
  set(s.ui.text, 'Visible', 'on', 'Position', [s.center 0.5 0], ...
                    'String', num2str(s.windowsize));
  set( s.ui.patch, 'XData', s.center + s.windowsize.*[-0.5 0.5 0.5 -0.5]);
  set( hObj, 'MyDragFcn', {@thumbresizefcn, eventdata.ClickedPoint(1)-s.center, ...
                   hAx} );
  set( hObj, 'MyStopDragFcn', @stopthumbresizefcn);
  retval = true;
end
%==========================================================================

%==========================================================================
function retval = thumbdragfcn( hObj, eventdata, clickpoint, hAx ) %#ok

hP = get(hAx, 'Parent');
s = getappdata(hP, 'Slider');
s.currentmarkerval = NaN;
s.center = max( min( eventdata.HitPoint(1)-clickpoint, s.limits(2)-0.5.*s.windowsize ), s.limits(1)+0.5.*s.windowsize ) ;
set(s.ui.text, 'String', num2str(s.center), 'Position', [s.center 0.5 0]);
set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
setappdata(hP,'Slider', s);
if strcmp(s.updatemode, 'live')
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
  fireUpdateEvent(slider(hP));
end
retval = true;
%==========================================================================

%==========================================================================
function retval = stopthumbdragfcn( hObj, eventdata ) %#ok

hAx = get(hObj,'Parent');
hP = get(hAx, 'Parent');
s = getappdata(hP, 'Slider');

set(s.ui.text, 'Visible', 'off');
set(s.ui.center_edit, 'String', num2str( s.center ) );

set( hObj, 'MyDragFcn', [] );

if strcmp(s.updatemode, 'delayed')
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
  fireUpdateEvent(slider(hP));
end
retval = true;
%==========================================================================

%==========================================================================
function retval = thumbresizefcn( hObj, eventdata, clickpoint, hAx )

hP = get(hAx, 'Parent');
s = getappdata(hP, 'Slider');

p = get( hObj, 'XData' );

if clickpoint>0 && eventdata.HitPoint(1)>=p(1)
  p(2:3) = min( s.limits(2), eventdata.HitPoint(1) );
elseif clickpoint<=0 && eventdata.HitPoint(1)<=p(2)
  p([1 4]) = max( s.limits(1), eventdata.HitPoint(1) );
end
  
s.windowsize = p(2)-p(1);
s.center = (p(2)+p(1))/2;
s.currentmarkerval = NaN;
setappdata(hP, 'Slider', s);

set(s.ui.text, 'String', num2str(s.windowsize), 'Position', [s.center 0.5 0]);
set(hObj, 'XData', p);

if strcmp(s.updatemode, 'live')
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
  fireUpdateEvent(slider(hP));
end

retval = true;
%==========================================================================

%==========================================================================
function retval = stopthumbresizefcn( hObj, eventdata ) %#ok

hAx = get(hObj,'Parent');
hP = get(hAx, 'Parent');
s = getappdata(hP, 'Slider');

set(s.ui.text, 'Visible', 'off');
set(s.ui.edit, 'String', num2str( s.windowsize ) );
set( s.ui.patch, 'XData', s.center + max( s.windowsize, ...
                                                  0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
set( hObj, 'MyDragFcn', [] );

if strcmp(s.updatemode, 'delayed')
  update_linkedaxes(s);
  %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
  fireUpdateEvent(slider(hP));
end

retval = true;
%==========================================================================

%==========================================================================
function stepbtndown(hObj, eventdata, stepsize) %#ok

hObj = get(hObj, 'Parent');
s = getappdata(hObj, 'Slider');

if strcmp( s.currentmarker, 'none')

  s = stepthumb( s, stepsize);

else
  
  n =  size(s.markers.(s.currentmarker), 1 );
  
  if stepsize>0
    if isnan(s.currentmarkerval)
      s.currentmarkerval = find( s.markers.(s.currentmarker)(:,1)> ...
                                 (s.center-0.5*s.windowsize), 1 );
      if isempty(s.currentmarkerval)
        s.currentmarkerval = 1;
      end
    else
      s.currentmarkerval = mod(s.currentmarkerval, n)+1;
    end
  else
    if isnan(s.currentmarkerval)
      s.currentmarkerval = find( s.markers.(s.currentmarker)(:,1)< ...
                                 (s.center-0.5*s.windowsize), 1, 'last' );
      if isempty(s.currentmarkerval)
        s.currentmarkerval = n;
      end
    else
      s.currentmarkerval = mod(s.currentmarkerval-2, n)+1;
    end    
  end

  if size(s.markers.(s.currentmarker),2)==2
    switch s.displaymode
      case 'strict'
       s.windowsize = min( diff(s.markers.(s.currentmarker)(s.currentmarkerval,:)), diff(s.limits));
     case '+50%'
       s.windowsize = min( 1.5*diff(s.markers.(s.currentmarker)(s.currentmarkerval,:)), diff(s.limits));      
     case 'window size'
    end
    stepsize = (mean(s.markers.(s.currentmarker)(s.currentmarkerval,:)) - s.center)./s.windowsize;
  else
    stepsize = (s.markers.(s.currentmarker)(s.currentmarkerval) - s.center)./ s.windowsize;
  end
   
  s = stepthumb(s, stepsize);
  
end
% $$$   
% $$$      idx = find( s.markers.(s.currentmarker)(:,1)>(s.center-0.5*s.windowsize+eps), 1 );
% $$$     if ~isempty(idx)
% $$$       if size(s.markers.(s.currentmarker),2)==2
% $$$         s.windowsize = min( diff(s.markers.(s.currentmarker)(idx,:)), ...
% $$$                             diff(s.limits));
% $$$         stepsize = (mean(s.markers.(s.currentmarker)(idx,:)) - s.center)./s.windowsize;
% $$$ 
% $$$       else
% $$$         stepsize = (s.markers.(s.currentmarker)(idx) - s.center)./ s.windowsize;
% $$$       end
% $$$       s = stepthumb( s, stepsize);
% $$$     end
% $$$   else
% $$$     idx = find( s.markers.(s.currentmarker)(:,1)<(s.center-0.5*s.windowsize-eps), ...
% $$$                 1,'last' );
% $$$     if ~isempty(idx)
% $$$       if size(s.markers.(s.currentmarker),2)==2
% $$$         s.windowsize = min( diff(s.markers.(s.currentmarker)(idx,:)), ...
% $$$                             diff(s.limits));
% $$$         stepsize = (mean(s.markers.(s.currentmarker)(idx,:)) - s.center)./s.windowsize;      
% $$$       else
% $$$         stepsize = (s.markers.(s.currentmarker)(idx) - s.center)./ ...
% $$$             s.windowsize;
% $$$       end
% $$$       s = stepthumb( s, stepsize);
% $$$     end
% $$$   end
% $$$ end

set(s.ui.edit, 'String', num2str(s.windowsize));

setappdata(hObj, 'Slider', s);

update_linkedaxes(s);  
%process_callbacks( s.updatefcn, hObj, s.center, s.windowsize );
fireUpdateEvent(slider(hObj));
  
%==========================================================================

%==========================================================================
function retval = axisdownfcn(hObj, eventdata)

if (~isempty(eventdata) && isfield(eventdata, 'Button' ) && eventdata.Button~=1) ...
      || (isfield(eventdata, 'HitObject') && eventdata.HitObject~=hObj)
  retval = false;
  return
end

hObj = get( hObj, 'Parent');
s = getappdata(hObj, 'Slider');

stepsize  = sign( eventdata.ClickedPoint(1) - s.center );

s = stepthumb( s, stepsize );

setappdata(hObj, 'Slider', s);

update_linkedaxes(s);
%process_callbacks( s.updatefcn, hObj, s.center, s.windowsize );
fireUpdateEvent(slider(hObj));

retval = true;
%==========================================================================

%==========================================================================
function s = stepthumb( s, stepsize )

s.center = max( min( s.center + stepsize.*s.windowsize, s.limits(2)-0.5.*s.windowsize ), s.limits(1)+0.5.*s.windowsize ) ;

set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5])
set( s.ui.center_edit, 'String', num2str( s.center ) );

%==========================================================================


%==========================================================================
function ResizeParent( hObj, eventdata) %#ok

slider = getappdata(hObj, 'Slider');

%get position in characters
old_units = get( hObj, 'Units');

set(hObj, 'Units', 'characters');
pos = get(hObj, 'Position');
set(hObj, 'Units', old_units);

label_width = min( 0.1*pos(3), 10 );
btn_width = min( 0.05.*pos(3), 4 );
edit_width = min( 0.1*pos(3), 10);
ax_width = pos(3) - 2*edit_width - 2*(label_width+btn_width);

edit_height = max( 1, pos(4)/2 );

xoffset = cumsum( [0 label_width btn_width ax_width btn_width label_width ...
                   edit_width edit_width]);

set(slider.ui.limedit(1), 'Units', 'characters', 'Position', [xoffset(1) 0 label_width edit_height]);
set(slider.ui.label(1), 'Units', 'characters', 'Position', [xoffset(1) edit_height label_width edit_height]);
set(slider.ui.button(1), 'Units', 'characters', 'Position', [xoffset(2) 0 btn_width-1 pos(4)]);
set(slider.ui.ax, 'Units', 'characters', 'Position', [xoffset(3) 0 ax_width pos(4)]);
set(slider.ui.button(2), 'Units', 'characters', 'Position', [xoffset(4)+1 0 btn_width-1 pos(4)]);
set(slider.ui.limedit(2), 'Units', 'characters', 'Position', [xoffset(5) 0 label_width edit_height]);
set(slider.ui.label(2), 'Units', 'characters', 'Position', [xoffset(5) edit_height label_width edit_height]);
set(slider.ui.center_edit, 'Units', 'characters', 'Position', [xoffset(6) ...
                    0 edit_width edit_height]);
set(slider.ui.label(3), 'Units', 'characters', 'Position', [xoffset(6) edit_height edit_width edit_height]);
set(slider.ui.edit, 'Units', 'characters', 'Position', [xoffset(7) 0 edit_width edit_height]);
set(slider.ui.label(4), 'Units', 'characters', 'Position', [xoffset(7) edit_height edit_width edit_height]);

set( [slider.ui.limedit slider.ui.label slider.ui.button slider.ui.edit slider.ui.center_edit ...
      slider.ui.ax], 'Units', 'normalized');
%==========================================================================

%==========================================================================
function changesize( hObj, eventdata) %#ok

hP = get( hObj, 'Parent');
s = getappdata(hP, 'Slider');
s.windowsize = min( str2num(get(hObj, 'String')), diff(s.limits)); %#ok
set(hObj, 'String', num2str(s.windowsize));
s.center = max( min( s.center, s.limits(2)-0.5.*s.windowsize ), s.limits(1)+0.5.*s.windowsize );
set(s.ui.center_edit, 'String', num2str(s.center));
s.currentmarkerval = NaN;
setappdata(hP, 'Slider', s);

set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);

update_linkedaxes(s);
%process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
fireUpdateEvent(slider(hP));
%==========================================================================

%==========================================================================
function changecenter( hObj, eventdata) %#ok

hP = get(hObj, 'Parent');
s = getappdata(hP, 'Slider');

s.center = max( min( str2num(get(hObj, 'String')), s.limits(2)- ...
                          0.5.*s.windowsize ), s.limits(1)+ ...
                     0.5.*s.windowsize ); %#ok
s.currentmarkerval = NaN;
set(hObj, 'String', num2str(s.center));
setappdata(hP, 'Slider', s);

set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5])

update_linkedaxes(s);
%process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
fireUpdateEvent(slider(hP));
%==========================================================================

%==========================================================================
function changemax( hObj, eventdata) %#ok

hP = get( hObj, 'Parent');
s = getappdata(hP, 'Slider');

newval = str2num(get(hObj, 'String')); %#ok

if newval<=s.limits(1)

  xl = get(s.ui.ax, 'XLim');
  set( hObj, 'String', xl(2) );

else

  s.limits(2) = newval;
  if diff(s.limits)<s.windowsize || s.center+0.5*s.windowsize>s.limits(2)
    s.windowsize = min( s.windowsize, diff(s.limits)); %#ok
    set(s.ui.edit, 'String', num2str(s.windowsize));
    s.center = max( min( s.center, s.limits(2)-0.5.*s.windowsize ), ...
                    s.limits(1)+0.5.*s.windowsize );
    set(s.ui.center_edit, 'String',  num2str(s.center));
    s.currentmarkerval = NaN;
    
    set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
    
    update_linkedaxes(s);
    %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
    fireUpdateEvent(slider(hP));
  end

  set(s.ui.ax, 'XLim', s.limits);  
  setappdata(hP, 'Slider', s);
  
end
%==========================================================================

%==========================================================================
function changemin( hObj, eventdata) %#ok

hP = get( hObj, 'Parent');
s = getappdata(hP, 'Slider');

newval = str2num(get(hObj, 'String')); %#ok

if newval>=s.limits(2)

  xl = get(s.ui.ax, 'XLim');
  set( hObj, 'String', xl(1) );

else

  s.limits(1) = newval;
  if diff(s.limits)<s.windowsize || s.center-0.5*s.windowsize<s.limits(1)
    s.windowsize = min( s.windowsize, diff(s.limits)); %#ok
    set(s.ui.edit, 'String', num2str(s.windowsize));
    s.center = max( min( s.center, s.limits(2)-0.5.*s.windowsize ), ...
                    s.limits(1)+0.5.*s.windowsize );
    set(s.ui.center_edit, 'String',  num2str(s.center));
    s.currentmarkerval = NaN;
    
    set( s.ui.patch, 'XData', s.center + max( s.windowsize, 0.01.*diff(s.limits) ).*[-0.5 0.5 0.5 -0.5]);
    
    update_linkedaxes(s);
    %process_callbacks( s.updatefcn, hP, s.center, s.windowsize );
    fireUpdateEvent(slider(hP));
  end
  
  set(s.ui.ax, 'XLim', s.limits);
  setappdata(hP, 'Slider', s);
  
end
%==========================================================================

%==========================================================================
function setmarker( hObj, eventdata, hP ) %#ok

if strcmp( get(hObj, 'Checked'), 'on')
    return
end

Sappdata = getappdata(hP, 'Slider');

set( Sappdata.ui.markermenu_items, 'Checked', 'off' );
set( hObj, 'Checked', 'on');

%delete current marker
try
    delete(Sappdata.ui.hmarker);
catch
end
    
%plot new marker
lbl = get( hObj, 'Label' );
switch lbl
 case 'none'
  Sappdata.ui.hmarker=[];
 otherwise
  if size(Sappdata.markers.(lbl),2)==2
    Sappdata.ui.hmarker = seg_plot( Sappdata.markers.( lbl ), 'Axis', Sappdata.ui.ax,...
                                    'EdgeColor', [1 0.75 0.5], 'FaceColor', ...
                                    [1 0.75 0.5], 'PlotArea',0,'Height', ...
                                    1,'YOffset',0.5 );
    
  else
    Sappdata.ui.hmarker = event_plot( Sappdata.markers.( lbl ), 'Axis', Sappdata.ui.ax );        
  end
  set( Sappdata.ui.hmarker, 'HitTest', 'off');
  set( Sappdata.ui.ax, 'Children', [Sappdata.ui.text; Sappdata.ui.hmarker(:); Sappdata.ui.patch]);
end

Sappdata.currentmarker = lbl;
Sappdata.currentmarkerval = NaN;
setappdata( hP, 'Slider', Sappdata);

%==========================================================================

%==========================================================================
function addmarker( hObj, eventdata, hP ) %#ok

s = slider( hP );

answer = inputdlg( { char( {'label of marker to be added or removed', ...
                    '(leave empty to generate a label from data below)'} ), ...
                    char( {'data of marker to be added', '(leave empty to remove marker with the label specified above)'} ) }, ...
                    'Add / Remove Marker' );

if ~isempty(answer)
  
  if isempty( answer{1} )
    marker_label = answer{2}( 1:min(end,10) );
  else
    marker_label = answer{1};
  end
  
  try
  
    if ~isempty(answer{2})
      marker_data = evalin('base', answer{2});
    else
      marker_data = [];
    end
  
    if ~isempty( marker_data )
  
      add_marker( s, marker_label, marker_data )
    
    else
    
      remove_marker( s, marker_label )
      
    end
    
  catch
    
    beep
    
  end
  
end


%==========================================================================

%==========================================================================
function setupdatemode( hObj, eventdata, hP, mode) %#ok

s = getappdata(hP, 'Slider');

s.updatemode = mode;

setappdata(hP, 'Slider', s);

if strcmp(s.updatemode, 'delayed')
    set(s.ui.updatemenu(1), 'Checked', 'on')
    set(s.ui.updatemenu(2), 'Checked', 'off')
else
    set(s.ui.updatemenu(2), 'Checked', 'on')
    set(s.ui.updatemenu(1), 'Checked', 'off')
end
%==========================================================================

%==========================================================================
function setdisplaymode( hObj, eventdata, hP, mode) %#ok

s = getappdata(hP, 'Slider');

s.displaymode = mode;

setappdata(hP, 'Slider', s);

if strcmp(s.displaymode, 'strict')
    set(s.ui.displaymenu(1), 'Checked', 'on')
    set(s.ui.displaymenu([2 3]), 'Checked', 'off')
elseif strcmp(s.displaymode, '+50%')
    set(s.ui.displaymenu(2), 'Checked', 'on')
    set(s.ui.displaymenu([1 3]), 'Checked', 'off')
else
    set(s.ui.displaymenu(3), 'Checked', 'on')
    set(s.ui.displaymenu([1 2]), 'Checked', 'off') 
end
%==========================================================================