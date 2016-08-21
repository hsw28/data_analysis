function h=cursor(varargin)
%CURSOR cursor constructor
%
%  h=CURSOR(param1,val1,...) constructs a cursor object with properties
%  set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes
%   X - x position
%   Y - y position
%   Style - cursor style ('vertical', 'horizontal', 'cross')
%   Color - cursor line color
%   LineStyle - cursor line style
%   LineWidth - cursor line width
%   SnapX - snapping in x direction
%   SnapY - snapping in y direction
%   MoveX - true/false determines if cursor can be dragged horizontally
%   MoveY - true/false determines if cursor can be dragged vertically
%   Size - length of cursor lines (scalar or two element vector)
%   ShowRuler - hide/show ruler while dragging
%   RulerColor - color of ruler
%   RulerLineStyle - line style of ruler
%   RulerLineWidth - line width of ruler
%   Text - text object
%   TextOffset - offset of text in pixels
%   TextPosX - x position of text
%   TextPosY - y position of text
%   Label - label object
%   LabelPosX - horizontal position of label
%   LabelPosY - vertical position of label
%   LabelOffset - offset of label in pixels
%   LabelShowMode - 'show', 'hide', 'drag', 'nodrag'
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar area parameters in arguments
p = {'X', 'Y', 'Style', 'Color', 'LineStyle', 'LineWidth', 'SnapX', 'SnapY', ...
     'MoveX', 'MoveY', 'Size', 'ShowRuler', 'RulerColor', 'RulerLineStyle', ...
     'RulerLineWidth', 'TextOffset', 'TextPosX', 'TextPosY', 'LabelPosX', ...
     'LabelPosY', 'LabelOffset', 'LabelShowMode'};

ind = find( ismember( lower(varargin(1:2:end)), lower(p) ) );
ind = [2*ind-1;2*ind];
args = varargin(ind(:));

%find parent parameter if any
parent_ind = find( strncmpi( varargin(1:2:end), 'parent',6 ) );
if ~isempty(parent_ind)
  parent = varargin{parent_ind*2};
else
  parent = gca;
end

%find remaining arguments and pass on to constructor
ind = setdiff(1:nargin,ind(:));
h=fkGraphics.cursor(varargin{ind},'Parent', double(parent));


%-------INITIALIZATION-------

%create graphical objects
hL(1) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
hL(2) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
hL(3) = line(NaN,NaN,'Parent',double(h),'LineStyle', 'none', 'Color', ...
             h.Color, 'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', ...
             h.Color, 'MarkerEdgeColor', [0 0 0]);
hL(4) = line([NaN NaN],[NaN NaN],'Parent',double(h),'LineStyle', h.RulerLineStyle, ...
             'Color', h.RulerColor, 'LineWidth', h.RulerLineWidth, 'HitTest', ...
             'off', 'Visible', onoff(h.ShowRuler));
hL(5) = createText(h);
hL(6) = createLabel(h);

%store the handles
h.hHandles=hL;

%set buttondown callbacks
updateCallbacks([], struct('affectedObject',h));


%-------LISTENERS-------

%create listener for when the cursor properties change
p = findallprops(h,{'Color','LineStyle','LineWidth'});
l = handle.listener(h, p,'PropertyPostSet', @changedCursorProps);

%create listener for when style changed
p=h.findprop('Style');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedCursorStyle);

%create listener for when labelshowmode has changed
p=h.findprop('LabelShowMode');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedLabelShowMode);

%add listener to monitor changes to xlim/ylim of parent axes
axparent = handle(ancestor(parent,'axes'));
p=[axparent.findprop('YLim') axparent.findprop('XLim')];
l(end+1)=handle.listener(axparent,p,'PropertyPostSet',{@changedSize,h});

%listener for size
p=h.findprop('Size');
l(end+1)=handle.listener(h,p,'PropertyPostSet',{@changedSize,h});

%listeners for x, y
p=[h.findprop('X') h.findprop('Y')];
l(end+1)=handle.listener(h,p,'PropertyPostSet',{@changedPos,h});

%listener for text position changes
p=findallprops(h,{'TextPosX','TextPosY','TextOffset'});
l(end+1)=handle.listener(h,p,'PropertyPostSet', @changedTextPos);

%listener for label position changes
p=findallprops(h,{'LabelPosX','LabelPosY','LabelOffset'});
l(end+1)=handle.listener(h,p,'PropertyPostSet', @changedLabelPos);

%listener for MoveX/MoveY changes
p = [h.findprop('MoveX') h.findprop('MoveY')];
l(end+1) = handle.listener(h,p,'PropertyPostSet', @updateCallbacks);

%listener for ruler property changes
p=findallprops(h, {'ShowRuler','RulerLineWidth','RulerColor', ...
                   'RulerLineStyle'});
l(end+1) = handle.listener(h,p,'PropertyPostSet', @changedRulerProps);


%listener for when user decided to delete Text or Label objects
l(end+1)=handle.listener(handle(h.hHandles(5)),'ObjectBeingDestroyed',{@destroyedText,h});
l(end+1)=handle.listener(handle(h.hHandles(6)),'ObjectBeingDestroyed',{@destroyedLabel,h});

%listener for when user decided to change Visible or String properties of Label
p=findprop(handle(h.hHandles(6)),'String');
l(end+1)=handle.listener(handle(h.hHandles(6)),p,'PropertyPostSet',{@changedLabelString,h});
p=findprop(handle(h.hHandles(6)),'Visible');
l(end+1)=handle.listener(handle(h.hHandles(6)),p,'PropertyPostSet',{@changedLabelVisible,h});


%-------SETTERS/GETTERS-------

%X,Y setters implement snapping
p=h.findprop('X'); %#ok
p.SetFunction = @changingX;
p=h.findprop('Y'); %#ok
p.SetFunction = @changingY;

%get text object
p=h.findprop('Text'); %#ok
p.GetFunction=@getTextHandle;

%get label object
p=h.findprop('Label'); %#ok
p.GetFunction=@getLabelHandle;

%-------FINALIZE-------

h.PropertyListeners = l;

%initial update
changedPos([],[],h);
changedSize([],[],h);

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end


%-------HELPER FUNCTIONS-------


function p=findallprops(h,props)
%FINDALLPROPS return a vector of properties
n = numel(props);
p = repmat(handle([]),1,n);
for k=n:-1:1
  p(k) = h.findprop(props{k});
end
   

function val=createText(h)
%CREATETEXT %create text object

%if valid object exists, delete it first
if numel(h.hHandles)>=5 && ishandle(h.hHandles(5))
  delete( h.hHandles(5))
end

%create new text object
val = text(NaN,NaN,'','Parent', double(h), 'HitTest', 'off', ...
           'Visible', 'on', 'VerticalAlignment', 'bottom', ...
           'HorizontalAlignment', 'center');
val = handle(val);


function val = createLabel(h)
%CREATELABEL create new label object

%if valid object exists, delete it first
if numel(h.hHandles)>=6 && ishandle(h.hHandles(6))
  delete(h.hHAndles(6));
end

%create new label object
val = text(NaN,NaN,'','Parent', double(h), ...
           'HitTest', 'off', 'VerticalAlignment', 'bottom', ...
           'HorizontalAlignment', 'left');
val = handle(val);


%-------LISTENER CALLBACK FUNCTIONS-------

%-------GETTERS/SETTERS-------

function val=getTextHandle(h,val) %#ok
val = h.hHandles(5);


function val=getLabelHandle(h,val) %#ok
val = h.hHandles(6);


function val=changingX(h,val)
if h.SnapX~=0
  val = round( val./h.SnapX ) .* h.SnapX;
end

function val=changingY(h,val)
if h.SnapY~=0
  val = round( val./h.SnapY ) .* h.SnapY;
end


%-------OBJECT DESTROYED FUNCTIONS-------


function destroyedText(hObj,eventdata,h) %#ok
if ~strcmp(h.BeingDeleted,'on') 
  h.hHandles(5) = createText(h);
  updateTextPos(h,'Text',5);
end


function destroyedLabel(hObj,eventdata,h) %#ok
if ~strcmp(h.BeingDeleted,'on')
  h.hHandles(6) = createLabel(h);
  updateTextPos(h,'Label',6);
  mode=updateLabelShow(h);
  if mode
    updateLabelContent(h);  
  end
end


%-------PROPERTY CHANGED FUNCTIONS-------


function changedLabelVisible(hProp,eventdata,h) %#ok
updateLabelShow(h);


function changedLabelString(hProp,eventdata,h) %#ok
updateLabelContent(h);


function changedLabelShowMode(hProp,eventdata) %#ok
mode=updateLabelShow(eventdata.affectedObject);
if mode
  updateLabelContent(h);
end


function changedRulerProps(hProp,eventdata) %#ok
h = eventdata.affectedObject;
set(h.hHandles(4),'LineStyle', h.RulerLineStyle, 'Color', h.RulerColor, ...
                  'LineWidth', h.RulerLineWidth);
if h.isDragging
  set(h.hHandles(4), 'Visible', onoff(h.ShowRuler));
end


function changedTextPos(hProp,eventdata) %#ok
updateTextPos(eventdata.affectedObject,'Text',5);


function changedLabelPos(hProp,eventdata) %#ok
updateTextPos(eventdata.affectedObject,'Label',6);


function changedSize(hProp,eventdata,h) %#ok
%determine size
parent=handle(ancestor(h,'axes'));
pos = get(parent,'PixelBound');

ylim = get(parent,'YLim');

if isinf(h.Size(end))
  ydata = ylim;
else
  ydata = [-0.5 0.5].*(h.Size(end).*diff(ylim))./pos(4) + h.Y;
end
set(h.hHandles(1), 'YData', ydata);

xlim = get(parent, 'XLim');
if isinf(h.Size(1))
  xdata = xlim;
else
  xdata = [-0.5 0.5].*(h.Size(1).*diff(xlim))./pos(3) + h.X;
end
set(h.hHandles(2), 'XData', xdata);

evdata = struct('affectedObject',h); 
changedTextPos(hProp,evdata);
changedLabelPos(hProp,evdata);


function changedPos(hProp,eventdata,h) %#ok

set(h.hHandles(1), 'XData', [h.X h.X] );
set(h.hHandles(2), 'YData', [h.Y h.Y]);
set(h.hHandles(3), 'XData', h.X, 'YData', h.Y);

if ~isinf(h.Size(1))
  tmp = get(h.hHandles(1), 'YData');
  set(h.hHandles(1),'YData',tmp+h.Y-mean(tmp));
end
if ~isinf(h.Size(end))
  tmp = get(h.hHandles(2), 'XData');  
  set(h.hHandles(2),'XData',tmp+h.X-mean(tmp));  
end

evdata = struct('affectedObject',h); 
changedTextPos(hProp,evdata);
changedLabelPos(hProp,evdata);

updateLabelContent(h);



function changedCursorStyle(hProp,eventdata) %#ok
h=eventdata.affectedObject;
switch h.Style
 case 'vertical'
  set(h.hHandles(2:3), 'Visible', 'off');
  set(h.hHandles(1), 'Visible', 'on');
 case 'horizontal'
  set(h.hHandles([1 3]), 'Visible', 'off');
  set(h.hHandles(2), 'Visible', 'on');  
 case 'cross'
  set(h.hHandles(1:3), 'Visible', 'on');
end

changedTextPos(hProp,eventdata);
changedLabelPos(hProp,eventdata);


function changedCursorProps(hProp,eventdata) %#ok
h=eventdata.affectedObject;
set(h.hHandles(1:2), 'Color', h.Color, 'LineStyle', h.LineStyle, 'LineWidth', ...
                  h.LineWidth);
set(h.hHandles(3),'MarkerFaceColor',h.Color,'Color',h.Color);


%-------UPDATE FUNCTIONS-------


function mode = updateLabelShow(h)
switch h.LabelShowMode
 case 'hide'
  mode=false;
 case 'show'
  mode = true;
 case 'nodrag'
  if h.isDragging
    mode = false;
  else
    mode = true;
  end
 case 'drag'
  if h.isDragging
    mode = true;
  else
    mode=false;
  end
end

set( h.hHandles(6), 'Visible', onoff(mode));


function updateTextPos(h,txt,idx)
%find x position

lblx = [txt 'PosX'];
lbly = [txt 'PosY'];
lblz = [txt 'Offset'];

if any(strncmpi({h.(lblx) h.(lbly)},'x',1)) || ...
      any(h.(lblz)~=0)
  
  parent = ancestor(h,'axes');
  pos = get(parent,'PixelBound');
  xl = get(parent,'XLim');
  yl = get(parent,'YLim');
  
end


switch h.Style
 case 'vertical'
  switch h.(lblx)
   case 'XE'
    x=xl(2);
   case 'XW'
    x=xl(1);
   otherwise
    x=h.X;
  end
 otherwise
  switch h.(lblx)
   case 'XE'
    x=xl(2);
   case 'XW'
    x=xl(1);
   case {'E','CE'}
    x=get(h.hHandles(2),'XData');
    x=x(2);    
   case {'W','CW'}
    x=get(h.hHandles(2),'XData');
    x=x(1);    
   case 'C'
    if strcmp(h.Style,'horizontal')
      x=mean(get(h.hHandles(2),'XData'));
    else
      x=h.X;
    end
  end
end


switch h.Style
 case 'horizontal'
  switch h.(lbly)
   case 'XN'
    y=yl(2);
   case 'XS'
    y=yl(1);
   otherwise
    y=h.Y;
  end
 otherwise
  switch h.(lbly)
   case 'XN'
    y=yl(2);
   case 'XS'
    y=yl(1);
   case {'N','CN'}
    y=get(h.hHandles(1),'YData');
    y=y(2);    
   case {'S','CS'}
    y=get(h.hHandles(1),'YData');
    y=y(1);    
   case 'C'
    if strcmp(h.Style,'vertical')
      y=mean(get(h.hHandles(1),'YData'));
    else
      y=h.Y;
    end
  end
end



if h.(lblz)(1)~=0
  x = x + diff(xl)*h.(lblz)(1)/pos(3);
end
if h.(lblz)(end)~=0
  y = y + diff(yl)*h.(lblz)(end)/pos(4);
end

set( h.hHandles(idx), 'Position', [x y 0]);

 

function updateCallbacks(hObj,eventdata) %#ok
h = eventdata.affectedObject;
if h.MoveX
  set(h.hHandles(1),'ButtonDownFcn', {@startDrag,h,1});
else
  set(h.hHandles(1),'ButtonDownFcn', '');
end
if h.MoveY
  set(h.hHandles(2),'ButtonDownFcn', {@startDrag,h,2});
else
  set(h.hHandles(2),'ButtonDownFcn', '');
end
if h.MoveX || h.MoveY
  set(h.hHandles(3),'ButtonDownFcn', {@startDrag,h,3});
else
  set(h.hHandles(3),'ButtonDownFcn', '');
end


function updateLabelContent(h)
switch h.Style
 case 'cross'
  txt = sprintf('x =%f    \ny =%f    ',h.X,h.Y);
  if h.isDragging
    txt = [txt sprintf('\ndx=%f    \ndy=%f    ',h.X-h.DragStartX,h.Y-h.DragStartY)];
  end
 case 'horizontal'
  txt = sprintf('y =%f    ',h.Y);
  if h.isDragging
    txt = [txt sprintf('\ndy=%f    ',h.Y-h.DragStartY)];
  end  
 case 'vertical'
  txt = sprintf('x =%f    ',h.X);
  if h.isDragging
    txt = [txt sprintf('\ndx=%f    ',h.X-h.DragStartX)];
  end 
end
set(h.hHandle(6), 'String', txt);


%-------DRAGGING FUNCTIONS-------


function startDrag(hObj,eventdata, hCursor,c) %#ok
hFig = ancestor(hObj,'figure');
set(hFig,'WindowButtonUpFcn', {@stopDrag, hCursor});
set(hFig,'WindowButtonMotionFcn', {@doDrag, hCursor, c});
hCursor.isDragging = true;
if ~strcmp(hCursor.Style,'horizontal')
  hCursor.DragStartX = hCursor.X;
else
  hCursor.DragStartX = mean(get(hCursor.hHandles(2),'XData'));
end
if ~strcmp(hCursor.Style,'vertical')
  hCursor.DragStartY = hCursor.Y;
else
  hCursor.DragStartY = mean(get(hCursor.hHandles(1),'YData'));  
end
mode=updateLabelShow(hCursor);
if mode
  updateLabelContent(hCursor);  
end
if hCursor.ShowRuler
  set(hCursor.hHandles(4), 'Visible', 'on','XData', [hCursor.X hCursor.X], 'YData', [hCursor.Y hCursor.Y]);
end

function stopDrag(hFig,eventdata,hCursor) %#ok
set(hFig,'WindowButtonUpFcn', '');
set(hFig,'WindowButtonMotionFcn', '');
hCursor.isDragging = false;
mode=updateLabelShow(hCursor);
if mode
  updateLabelContent(hCursor);
end
set(hCursor.hHandles(4), 'Visible', 'off');

function doDrag(hFig,eventdata, h,c) %#ok

hAx = ancestor(h, 'axes');
new_pos = get( hAx, 'CurrentPoint');

old_x = h.X;
old_y = h.Y;

m = get(hFig, 'CurrentModifier');

mshift = any(strcmp(m,'shift'));
mctrl = any(strcmp(m,'control'));

if (c==2 || c==3) && h.MoveY && ~mshift
  h.Y = new_pos(1,2);
else
  h.Y = h.DragStartY;
end
if (c==1 || c==3) && h.MoveX && ~mctrl
  h.X = new_pos(1,1);
else
  h.X = h.DragStartX;
end

if h.ShowRuler
  set( h.hHandles(4), 'XData', [h.DragStartX h.X], 'YData', [h.DragStartY h.Y]);
end


%send event, but only if X has changed for vertical/cross cursors and/or
%if Y has changed for horizontal/cross cursors
if (~strcmp(h.Style,'vertical') && old_y~=h.Y) || ...
      (~strcmp(h.Style,'horizontal') && old_x~=h.X)
  hEvent = handle.EventData(h, 'CursorChanged');
  send(h, 'CursorChanged', hEvent);
end