function h=rangecursor(varargin)
%RANGECURSOR range cursor constructor
%
%  h=CURSOR(param1,val1,...) constructs a cursor object with properties
%  set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes
%   XLim - x range
%   YLim - y range
%   Style - cursor style ('vertical', 'horizontal', 'cross')
%   Color - cursor line color
%   LineStyle - cursor line style
%   LineWidth - cursor line width
%   SnapX - snapping in x direction
%   SnapY - snapping in y direction
%   MoveX - true/false determines if cursor can be dragged horizontally
%   MoveY - true/false determines if cursor can be dragged vertically
%   Alpha - transparency of cursor area
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
%   LabelPos - positin of label 'axes','cursor','center'
%   LabelShowMode - 'show', 'hide', 'drag', 'nodrag'

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar area parameters in arguments
p = {'XLim', 'YLim', 'Style', 'Color', 'LineStyle', 'LineWidth', 'SnapX', 'SnapY', ...
     'MoveX', 'MoveY', 'Alpha', 'Size', 'ShowRuler', 'RulerColor', 'RulerLineStyle', ...
     'RulerLineWidth', 'TextOffset', 'TextPosX', 'TextPosY', 'LabelPos', ...
     'LabelShowMode'};

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
h=fkGraphics.rangecursor(varargin{ind},'Parent', double(parent));


%-------INITIALIZATION-------

%create graphical objects
hL(9) = patch(NaN,NaN,h.Color,'Parent',double(h),'LineStyle', 'none', ...
              'FaceAlpha', h.Alpha);

%left line
hL(1) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
%right line
hL(2) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
%top line
hL(3) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
%bottom line
hL(4) = line([NaN NaN],[NaN NaN],'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);

%corners
%top left
hL(5) = line(NaN,NaN,'Parent',double(h),'Color',[0 0 0],'Marker', 's', ...
             'MarkerSize', 6, 'MarkerFaceColor', [0 0 0]);
%top right
hL(6) = line(NaN,NaN,'Parent',double(h),'Color',[0 0 0],'Marker', 's', ...
             'MarkerSize', 6, 'MarkerFaceColor', [0 0 0]);
%bottom right
hL(7) = line(NaN,NaN,'Parent',double(h),'Color',[0 0 0],'Marker', 's', ...
             'MarkerSize', 6, 'MarkerFaceColor', [0 0 0]);
%bottom left
hL(8) = line(NaN,NaN,'Parent',double(h),'Color',[0 0 0],'Marker', 's', ...
             'MarkerSize', 6, 'MarkerFaceColor', [0 0 0]);

hL(10) = createText(h);
hL(11:14) = createLabel(h,11:14);

set(hL(11), 'Rotation', 90);
set(hL(12), 'Rotation', -90);
set(hL(14), 'VerticalAlignment', 'top');

hL(15) = line([NaN NaN],[NaN NaN],'Parent',double(h),'LineStyle', h.RulerLineStyle, ...
             'Color', h.RulerColor, 'LineWidth', h.RulerLineWidth, 'HitTest', ...
             'off', 'Visible', onoff(h.ShowRuler));

%store the handles
h.hHandles=hL;

%set buttondown callbacks
updateCallbacks([], struct('affectedObject',h));



%-------LISTENERS-------

%create listener for when the cursor properties change
p = [h.findprop('Color') h.findprop('LineStyle') ...
    h.findprop('LineWidth') h.findprop('Alpha')];
l = handle.listener(h, p,'PropertyPostSet', @changedCursorProps);

%create listener for when style changed
p=h.findprop('Style');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedCursorStyle);

axparent = handle(ancestor(parent,'axes'));
p=[axparent.findprop('YLim') axparent.findprop('XLim')];
l(end+1)=handle.listener(axparent,p,'PropertyPostSet',{@changedSize,h});

%listener for size
p=h.findprop('Size');
l(end+1)=handle.listener(h,p,'PropertyPostSet',{@changedSize,h});

%listeners for xlim, ylim
p=h.findprop('XLim');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedXLim);
p=h.findprop('YLim');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedYLim);

p=h.findprop('X');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedX);
p=h.findprop('Y');
l(end+1)=handle.listener(h,p,'PropertyPostSet',@changedY);

%listener for text position changes
p=findallprops(h,{'TextPosX','TextPosY','TextOffset'});
l(end+1)=handle.listener(h,p,'PropertyPostSet', @changedTextPos);

%listener for label position changes
p=findallprops(h,{'LabelPos'});
l(end+1)=handle.listener(h,p,'PropertyPostSet', @changedLabelPos);

p=findallprops(h,{'LabelSHowMode'});
l(end+1)=handle.listener(h,p,'PropertyPostSet', @changedLabelShowMode);

%listener for MoveX/MoveY changes
p = [h.findprop('MoveX') h.findprop('MoveY')];
l(end+1) = handle.listener(h,p,'PropertyPostSet', @updateCallbacks);

%listener for ruler property changes
p=findallprops(h, {'ShowRuler','RulerLineWidth','RulerColor', ...
                   'RulerLineStyle'});
l(end+1) = handle.listener(h,p,'PropertyPostSet', @changedRulerProps);


%listener for when user decided to delete Text or Label objects
l(end+1)=handle.listener(handle(h.hHandles(10)),'ObjectBeingDestroyed',{@destroyedText,h});
l(end+1)=handle.listener(handle(h.hHandles(11)),'ObjectBeingDestroyed',{@destroyedLabel,h,11});
l(end+1)=handle.listener(handle(h.hHandles(11)),'ObjectBeingDestroyed',{@destroyedLabel,h,12});
l(end+1)=handle.listener(handle(h.hHandles(11)),'ObjectBeingDestroyed',{@destroyedLabel,h,13});
l(end+1)=handle.listener(handle(h.hHandles(11)),'ObjectBeingDestroyed',{@destroyedLabel,h,14});



%-------SETTERS/GETTERS-------

%XLim,YLim setters implement snapping
p=h.findprop('XLim'); %#ok
p.SetFunction = @changingXRange;

p=h.findprop('YLim'); %#ok
p.SetFunction = @changingYRange;

%get text object
p=h.findprop('Text'); %#ok
p.GetFunction=@getTextHandle;

%get label object
p=h.findprop('Label'); %#ok
p.GetFunction=@getLabelHandle;


%-------FINALIZE-------

h.PropertyListeners = l;

%initial update

changedPos(h);
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
if numel(h.hHandles)>=10 && ishandle(h.hHandles(10))
  delete( h.hHandles(10))
end

%create new text object
val = text(NaN,NaN,'','Parent', double(h), 'HitTest', 'off', ...
           'Visible', 'on', 'VerticalAlignment', 'bottom', ...
           'HorizontalAlignment', 'center');
val = handle(val);


function val = createLabel(h,idx)
%CREATELABEL create new label object

%if valid object exists, delete it first
if numel(h.hHandles)>=max(idx) && all(ishandle(h.hHandles(idx)))
  delete(h.hHAndles(idx));
end

%create new label object
for k=1:numel(idx)
  val(k) = text(NaN,NaN,'','Parent', double(h), ...
                'HitTest', 'off', 'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', 'center');
end
val = handle(val);


%-------LISTENER CALLBACK FUNCTIONS-------

%-------GETTERS/SETTERS-------

function val=getTextHandle(h,val) %#ok
val = h.hHandles(10);


function val=getLabelHandle(h,val) %#ok
val = h.hHandles(11:14);


function val=changingXRange(h,val)
if h.SnapX~=0
  val = round( val./h.SnapX ) .* h.SnapX;
end
val = sort(val);

function val=changingYRange(h,val)
if h.SnapY~=0
  val = round( val./h.SnapY ) .* h.SnapY;
end
val=sort(val);


%-------OBJECT DESTROYED FUNCTIONS-------


function destroyedText(hObj,eventdata,h) %#ok
if ~strcmp(h.BeingDeleted,'on') 
  h.hHandles(10) = createText(h);
  updateTextPos(h,'Text',10);
end


function destroyedLabel(hObj,eventdata,h,idx) %#ok
if ~strcmp(h.BeingDeleted,'on')
  for k=1:numel(idx)
    h.hHandles(10+k) = createLabel(h,10+k);
  end
  updateTextPos(h,'Label',6);
  mode=updateLabelShow(h);
  if mode
    updateLabelContent(h);  
  end
end


%-------PROPERTY CHANGED FUNCTIONS-------

function changedX(hProp,eventdata) %#ok
h=eventdata.affectedObject;
h.XLim = h.X + h.XLim - mean(h.XLim);

function changedY(hProp,eventdata) %#ok
h=eventdata.affectedObject;
h.YLim = h.Y + h.YLim - mean(h.YLim);

function changedXLim(hProp, eventdata) %#ok
h=eventdata.affectedObject;
changedPos(h);

function changedYLim(hProp, eventdata) %#ok
h=eventdata.affectedObject;
changedPos(h);

function changedLabelShowMode(hProp,eventdata) %#ok
mode=updateLabelShow(eventdata.affectedObject);
if mode
  updateLabelContent(h);
end


function changedRulerProps(hProp,eventdata) %#ok
h = eventdata.affectedObject;
set(h.hHandles(15),'LineStyle', h.RulerLineStyle, 'Color', h.RulerColor, ...
                  'LineWidth', h.RulerLineWidth);
if h.isDragging
  set(h.hHandles(15), 'Visible', onoff(h.ShowRuler));
end


function changedTextPos(hProp,eventdata) %#ok
updateTextPos(eventdata.affectedObject);


function changedLabelPos(hProp,eventdata) %#ok
updateLabelPos(eventdata.affectedObject);


function changedSize(hProp,eventdata,h) %#ok
%determine size
parent=handle(ancestor(h,'axes'));
pos = get(parent,'PixelBound');

%compute ydata of left and right lines
ylim = get(parent,'YLim');
if isinf(h.Size(end)) % || ~strcmp(h.Style, 'cross')
  set(h.hHandles(1:2),'YData', ylim);
  ydata=ylim([1 1 2 2]);
else
  set(h.hHandles(1:2),'YData', [-0.5 0.5].*(h.Size(end).*diff(ylim))./pos(4) + h.YLim);  
  ydata = h.YLim([1 1 2 2]);
end

if strcmp(h.Style, 'vertical')
  set(h.hHandles(9), 'YData', ydata);
end


%compute xdata of top and bottom lines
xlim = get(parent,'XLim');
if isinf(h.Size(1)) % || ~strcmp(h.Style,'cross')
  set(h.hHandles(3:4), 'XData', xlim);
  xdata=xlim([1 2 2 1]);
else
  set(h.hHandles(3:4), 'XData', [-0.5 0.5].*(h.Size(1).*diff(xlim))./pos(3) + h.XLim);
  xdata = h.XLim([1 2 2 1]);
end

if strcmp(h.Style, 'horizontal')
  set(h.hHandles(9), 'XData', xdata);  
end




evdata = struct('affectedObject',h); 
changedTextPos(hProp,evdata);
changedLabelPos(hProp,evdata);


function changedPos(h)

set(h.hHandles(1),'XData', [0 0]+h.XLim(1));
set(h.hHandles(2),'XData', [0 0]+h.XLim(2));

set(h.hHandles(3),'YData', [0 0]+h.YLim(2));
set(h.hHandles(4),'YData', [0 0]+h.YLim(1));

if any(~isinf(h.Size))
 parent=handle(ancestor(h,'axes'));
 pos = get(parent,'PixelBound'); 
 ylim = get(parent,'YLim');
 xlim = get(parent,'XLim');
end

if ~isinf(h.Size(end))
  ydata = [-0.5 0.5].*(h.Size(end).*diff(ylim))./pos(4) + h.YLim;
  set(h.hHandles(1:2),'YData',ydata);
end
if ~isinf(h.Size(1))
  xdata = [-0.5 0.5].*(h.Size(1).*diff(xlim))./pos(3) + h.XLim;
  set(h.hHandles(3:4),'XData',xdata);  
end

%compute coordinates for patch
switch h.Style
 case 'vertical'
  set( h.hHandles(9), 'XData', h.XLim([1 2 2 1]));  
  set( h.hHandles([5 8]), 'XData', h.XLim(1) );  
  set( h.hHandles([6 7]), 'XData', h.XLim(2) );  
 case 'horizontal'
  set( h.hHandles(9), 'YData', h.YLim([1 1 2 2]));
  set( h.hHandles([5 6]), 'YData', h.YLim(2) );  
  set( h.hHandles([7 8]), 'YData', h.YLim(1) );  
 case 'cross'
  set( h.hHandles(9), 'XData', h.XLim([1 2 2 1]), 'YData', h.YLim([1 1 2 2]));
  set( h.hHandles(5), 'XData', h.XLim(1), 'YData', h.YLim(2) );  
  set( h.hHandles(6), 'XData', h.XLim(2), 'YData', h.YLim(2) );  
  set( h.hHandles(7), 'XData', h.XLim(2), 'YData', h.YLim(1) );  
  set( h.hHandles(8), 'XData', h.XLim(1), 'YData', h.YLim(1) );  

end

evdata = struct('affectedObject',h); 
changedTextPos([],evdata);
changedLabelPos([],evdata);

updateLabelContent(h);

set(h.PropertyListeners,'Enabled','off');
h.Y=mean(h.YLim);
h.X=mean(h.XLim);
set(h.PropertyListeners,'Enabled','on');


function changedCursorStyle(hProp,eventdata) %#ok
h=eventdata.affectedObject;
switch h.Style
 case 'vertical'
  set(h.hHandles([3:8 13 14]), 'Visible', 'off');
  set(h.hHandles([1:2 11 12]), 'Visible', 'on');
  ydata = get( h.hHandles(1), 'YData');
  set(h.hHandles(9), 'YData', ydata([1 1 2 2]), 'XData', h.XLim([1 2 2 1]));
 case 'horizontal'
  set(h.hHandles([1:2 5:8 11 12]), 'Visible', 'off');
  set(h.hHandles([3:4 13 14]), 'Visible', 'on');  
  xdata = get( h.hHandles(3), 'XData');
  set(h.hHandles(9), 'XData', xdata([1 2 2 1]),'YData',h.YLim([1 1 2 2]));  
 case 'cross'
  set(h.hHandles([1:8 11:14]), 'Visible', 'on');
  set(h.hHandles(9), 'XData', h.XLim([1 2 2 1]),'YData',h.YLim([1 1 2 2]));  
end

changedTextPos(hProp,eventdata);
changedLabelPos(hProp,eventdata);
updateLabelShow(h);

function changedCursorProps(hProp,eventdata) %#ok
h=eventdata.affectedObject;
set(h.hHandles(1:4), 'Color', h.Color, 'LineStyle', h.LineStyle, 'LineWidth', ...
                  h.LineWidth);
set(h.hHandles(9),'FaceColor', h.Color, 'FaceAlpha', h.Alpha);
set(h.hHandles(11:14), 'Color', h.Color);


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

if ~strcmp(h.Style, 'vertical')
  set( h.hHandles(13:14), 'Visible', onoff(mode));
else
  set( h.hHandles(13:14), 'Visible', 'off' );
end
if ~strcmp(h.Style, 'horizontal')
  set( h.hHandles(11:12), 'Visible', onoff(mode));
else
  set( h.hHandles(11:12), 'Visible', 'off' );
end


function updateLabelPos(h)

if strcmp(h.LabelPos,'axes') || ~strcmp(h.Style','cross')
  parent = ancestor(h,'axes');
  xl = get(parent, 'XLim');
  yl = get(parent, 'YLim');
end

if ~strcmp(h.Style, 'horizontal')
  xdata = get(h.hHandles(3), 'XData');
  xm = mean(h.XLim);
else
  xdata = xl;
  xm = mean(xl);
end
if ~strcmp(h.Style, 'vertical')
  ydata = get(h.hHandles(1), 'YData');
ym = mean(h.YLim);
else
  ydata = ylim;
  ym = mean(yl);
end

switch h.LabelPos
 case 'axes'
  set(h.hHandles(11), 'Position', [xl(1) ym 0]);
  set(h.hHandles(12), 'Position', [xl(2) ym 0]);
  set(h.hHandles(13), 'Position', [xm yl(2) 0]);
  set(h.hHandles(14), 'Position', [xm yl(1) 0]);
 case 'cursor'
  set(h.hHandles(11), 'Position', [xdata(1) ym 0]);
  set(h.hHandles(12), 'Position', [xdata(2) ym 0]);
  set(h.hHandles(13), 'Position', [xm ydata(2) 0]);
  set(h.hHandles(14), 'Position', [xm ydata(1) 0]);
 case 'center'
  set(h.hHandles(11), 'Position', [h.XLim(1) ym 0]); 
  set(h.hHandles(12), 'Position', [h.XLim(2) ym 0]);
  set(h.hHandles(13), 'Position', [xm h.YLim(2) 0]);
  set(h.hHandles(14), 'Position', [xm h.YLim(1) 0]);
end


function updateLabelContent(h)

if h.isDragging
  c = h.DragIndex;
else
  c = 9;
end

if c==9
  dx = mean(h.XLim)-h.DragStartX;
else
  dx = h.XLim-h.DragStartX;
end
if c==9
  dy = mean(h.YLim)-h.DragStartY;
else
  dy = h.YLim-h.DragStartY;
end
  

%update left label?
if c==1 || c==5 || c==8 || c==9
  txt = sprintf('xl=%f',h.XLim(1));
  if h.isDragging
    txt = [txt sprintf('\ndx=%f',dx(1))];
  end
  set(h.hHandle(11),'String',txt);
end
%update right label?
if c==2 || c==6 || c==7 || c==9
  txt = sprintf('xr=%f',h.XLim(2));
  if h.isDragging
    txt = [txt sprintf('\ndx=%f',dx(end))];
  end
  set(h.hHandle(12),'String',txt);
end
%update top label?
if c==3 || c==5 || c==6 || c==9
  txt = sprintf('yt=%f',h.YLim(2));
  if h.isDragging
    txt = [txt sprintf('\ndy=%f',dy(end))];
  end
  set(h.hHandle(13),'String',txt);
end
%update bottom label?
if c==4 || c==7 || c==8 || c==9
  txt = sprintf('yb=%f',h.YLim(1));
  if h.isDragging
    txt = [txt sprintf('\ndy=%f',dy(1))];
  end
  set(h.hHandle(14),'String',txt);
end


function updateTextPos(h)
%find x position

lblx = 'TextPosX';
lbly = 'TextPosY';
lblz = 'TextOffset';
idx = 10;

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
   case {'E','CE'}
    x=h.XLim(1);
   case {'W','CW'}
    x=h.XLim(2);
   case 'C'
    x=mean(h.XLim);
  end
 otherwise
  switch h.(lblx)
   case 'XE'
    x=xl(2);
   case 'XW'
    x=xl(1);
   case 'E'
    x=get(h.hHandles(3),'XData');
    x=x(2);    
   case 'W'
    x=get(h.hHandles(3),'XData');
    x=x(1);
   case 'CE'
    x=h.XLim(2);
   case 'CW'
    x=h.XLim(1);
   case 'C'
    if strcmp(h.Style,'horizontal')
      x=mean(get(h.hHandles(3),'XData'));
    else
      x=mean(h.XLim);
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
   case {'N','CN'}
    y=h.YLim(2);
   case {'S','CS'}
    y=h.YLim(1);
   otherwise
    y=mean(h.YLim);
  end
 otherwise
  switch h.(lbly)
   case 'XN'
    y=yl(2);
   case 'XS'
    y=yl(1);
   case 'N'
    y=get(h.hHandles(1),'YData');
    y=y(2);    
   case 'S'
    y=get(h.hHandles(1),'YData');
    y=y(1);
   case 'CN'
    y=h.YLim(2);
   case 'CS'
    y=h.YLim(1);
   case 'C'
    if strcmp(h.Style,'vertical')
      y=mean(get(h.hHandles(1),'YData'));
    else
      y=mean(h.YLim);
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
  set(h.hHandles(2),'ButtonDownFcn', {@startDrag,h,2});  
else
  set(h.hHandles(1:2),'ButtonDownFcn', '');
end
if h.MoveY
  set(h.hHandles(3),'ButtonDownFcn', {@startDrag,h,3});
  set(h.hHandles(4),'ButtonDownFcn', {@startDrag,h,4});
else
  set(h.hHandles(3:4),'ButtonDownFcn', '');
end
if h.MoveX || h.MoveY
  for k=5:9
    set(h.hHandles(k),'ButtonDownFcn', {@startDrag,h,k});
  end
else
  set(h.hHandles(5:9),'ButtonDownFcn', '');
end


%-------DRAGGING FUNCTIONS-------

function startDrag(hObj,eventdata, h,c) %#ok
hFig = ancestor(hObj,'figure');
set(hFig,'WindowButtonUpFcn', {@stopDrag,h});
set(hFig,'WindowButtonMotionFcn', {@doDrag, h,c});

hAx = ancestor(h, 'axes');
new_pos = get( hAx, 'CurrentPoint');
if ~strcmp(h.Style,'horizontal')
  switch c
   case {1 5 8}
    h.DragStartX = h.XLim(1);
   case {2 6 7}
    h.DragStartX = h.XLim(2);
   case {3 4}
    h.DragStartX = new_pos(1,1); %mean(h.XLim);
   case 9
    h.DragStartX = mean(h.XLim);
  end
else
  h.DragStartX = new_pos(1,1); %mean(get(h.hHandles(3),'XData'));
end
if ~strcmp(h.Style,'vertical')
  switch c
   case {3 5 6}
    h.DragStartY = h.YLim(2);
   case {4 7 8}
    h.DragStartY = h.YLim(1);
   case {1 2}
    h.DragStartY = new_pos(1,2); %mean(h.YLim);
   case 9
    h.DragStartY = mean(h.YLim);
  end
else
  h.DragStartY = new_pos(1,2); %mean(get(h.hHandles(1), 'YData'));
end

updateLabelContent(h);  

h.isDragging=true;
h.DragIndex = c;

updateLabelShow(h);


if h.ShowRuler
  set(h.hHandles(15), 'Visible', 'on','XData', [h.DragStartX h.DragStartX], 'YData', [h.DragStartY h.DragStartY]);
end



function stopDrag(hFig,eventdata,h) %#ok
set(hFig,'WindowButtonUpFcn', '');
set(hFig,'WindowButtonMotionFcn', '');

h.isDragging=false;
mode=updateLabelShow(h);
if mode
  updateLabelContent(h);
end
set(h.hHandles(15),'Visible','off');


function doDrag(hFig,eventdata, h,c) %#ok

hAx = ancestor(h, 'axes');
new_pos = get( hAx, 'CurrentPoint');

old_x = h.XLim;
old_y = h.YLim;

m = get(hFig, 'CurrentModifier');

mshift = any(strcmp(m,'shift'));
mctrl = any(strcmp(m,'control'));

x = new_pos(1,1);
y = new_pos(1,2);

if (c==1 || c==5 || c==8)
  if h.MoveX && ~mshift
    if new_pos(1,1)>old_x(2)
      new_pos(1,1) = old_x(2);
    end
    h.XLim = [new_pos(1,1) old_x(2)];
  else
    h.XLim = [h.DragStartX old_x(2)];
  end
  x = h.XLim(1);
end

if (c==2 || c==6 || c==7)
  if h.MoveX && ~mshift
    if new_pos(1,1)<old_x(1)
      new_pos(1,1) = old_x(1);
    end  
    h.XLim = [old_x(1) new_pos(1,1)];  
  else
    h.XLim = [old_x(1) h.DragStartX];  
  end
  x = h.XLim(2);
end

if (c==3 || c==5 || c==6) 
  if h.MoveY && ~mctrl
    if new_pos(1,2)<old_y(1)
      new_pos(1,2) = old_y(1);
    end  
    h.YLim = [old_y(1) new_pos(1,2)];  
  else
    h.YLim = [old_y(1) h.DragStartY];
  end
  y = h.YLim(2);
end

if (c==4 || c==7 || c==8)
  if h.MoveY && ~mctrl
    if new_pos(1,2)>old_y(2)
      new_pos(1,2) = old_y(2);
    end  
    h.YLim = [new_pos(1,2) old_y(2)];  
  else
    h.YLim = [h.DragStartY old_y(2)];
  end
  y = h.YLim(1);
end

if c==9
  if  ~strcmp(h.Style, 'horizontal')
    if h.MoveX && ~mshift
      h.XLim = old_x - mean(old_x) + new_pos(1,1);
    else
      h.XLim = old_x - mean(old_x) + h.DragStartX;
    end
  end
  if ~strcmp(h.Style, 'vertical')
    if h.MoveY && ~mctrl
      h.YLim = old_y - mean(old_y) + new_pos(1,2);
    else
      h.YLim = old_y - mean(old_y) + h.DragStartY;
    end
  end
end

if h.ShowRuler
  if c==1 || c==2 || (c>=5 && c<=9)
    set( h.hHandles(15), 'XData', [h.DragStartX x]);
  end
  if c==3 || c==4 || (c>=5 && c<=9)
    set(h.hHandles(15), 'YData', [h.DragStartY y]);
  end
end

%send event
if ~isequal(old_y,h.YLim) || ~isequal(old_x,h.XLim)
  hEvent = handle.EventData(h, 'CursorChanged');
  send(h, 'CursorChanged', hEvent);
end
