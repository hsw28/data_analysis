function uireconstruction( r, varargin )
%UIRECONSTRUCTION gui for stimulus reconstruction exploration
%
%  UIRECONSTRUCTION(r) where r is a reconstruction engine
%


%parse arguments
args = struct( 'radon_engine', [], ...
               'regression_engine', [] );
args = parseArgs( varargin, args );

if nargin<1
  error('uireconstruction:invalidInput', 'Missing reconstruction engine')
end

args.reconstruct_engine = r;

%create hash table
h = mhashtable();

%create figure
[hFig, toplayout, cmdline, plotlayout] = createfigure();

%create options dialog
[javacomp, tabs, tablemodels, tables, slicerobj] = create_optionsdlg(args,hFig); %#ok

%setup axes, create images and lines
[hAx, hImg, hLines] = createplots(hFig, plotlayout, h);

%get max and min time
tmp = get( args.reconstruct_engine, 'spikes');
if isempty(tmp)
  tmp = args.reconstruct_engine.defaultspikes;
end
limits = [min(vertcat(tmp{:})) max(vertcat(tmp{:}))];

%create slider
p = toplayout.childmatrix;

hSlider = createslider( p(2,1), hAx([1 2 4 6 8]), limits, mean(limits), 2 );

%setup toolbar
T = createtoolbar( hFig, cmdline, javacomp, ...
                   [hLines.behav_line, hLines.activecells_line, hLines.ncells_line], ...
                   {'show/hide behavior', 'show/hide # active cells', 'show/hide # of spikes in bin'} );

%add callback to reconstruction engine
remove_callback( args.reconstruct_engine );
add_callback( args.reconstruct_engine, {@enginechange, hFig, 'reconstruction'} );

%add callback to reconstruction engine
if ~isempty( args.radon_engine )
  remove_callback( args.radon_engine );
  add_callback( args.radon_engine, {@enginechange, hFig, 'radon'} );
end

%add callback to reconstruction engine
if ~isempty(args.regression_engine)
  remove_callback( args.regression_engine );
  add_callback( args.regression_engine, {@enginechange, hFig, 'regression'} );
end

%store data in hash table
h.put('engine', args.reconstruct_engine);
h.put('engine_radon', args.radon_engine);
h.put('engine_regression', args.regression_engine);

h.put('toplayout', toplayout);
h.put('axeslayout', plotlayout);

h.put('slicer', slicerobj);

h.put('tablemodels_reconstruction', tablemodels.reconstruction);
h.put('tables_reconstruction', tables.reconstruction);

if ~isempty(args.radon_engine)
  h.put('tablemodels_radon', tablemodels.radon);
  h.put('tables_radon', tables.radon);
end

if ~isempty(args.regression_engine)
  h.put('tablemodels_regression', tablemodels.regression);
  h.put('tables_regression', tables.regression);  
end

h.put('axes', hAx);

h.put('image_estimate', hImg(1));
h.put('image_activity', hImg(2));
h.put('image_radon', hImg(3));

h.put('lines_estimate', hLines.behav_line);
h.put('lines_activity', [hLines.activecells_line hLines.ncells_line] );

h.put('peaks_radon', hLines.radonpeaks_line);
h.put('ellipses_radon', []);
h.put('lines_radon', []);
h.put('text_radon', []);
h.put('lines_regression', [hLines.r2_line hLines.slope_line]);
h.put('regress_line', hLines.regression_line);

h.put('slider', hSlider);
h.put('toggles', T);

set(plotlayout, 'height', [1 1 0 0]);

%save hash in application data
setappdata(hFig, 'replay', h);

fireUpdateEvent(hSlider);


%---create figure and main layout---------------------------------------
%in: 
%out: hFig, toplayout, cmdline, plotlayout
function [hFig, toplayout, cmdline, plotlayout] = createfigure()

%create figure
hFig = figure('DeleteFcn', @figdelete, 'ToolBar', 'none', 'MenuBar', 'none', ...
              'Renderer', 'OpenGL');
colormap hot;
event_dispatch(hFig);

%create top level layout manager
toplayout  = layoutmanager(hFig, 2, 1, 'fcn', @uipanel, 'height', [1 -2], 'argin', ...
                           {'BorderType', 'none', 'BackgroundColor', [0.2 0.2 0.2]}, 'YSpacing', 0);

hPanel = toplayout.childmatrix;

%create command line
cmdline = javacommandline( hFig );

%create layout manager for engines and axes
plotlayout = layoutmanager(hPanel(1,1), 4, 1, 'height', [1 1 1 1], 'z', 2, 'xoffset', ...
                    10, 'yoffset', 4, 'yspacing', 4);
%-----------------------------------------------------------------------

%---create slider-------------------------------------------------------
%in: parent, hAx, lim, center, wndsize
%out: hSlider
function hSlider = createslider(parent, hAx, lim, center, wndsize)

%create slider
hSlider = slider(parent, 'limits',lim, 'windowsize', wndsize, ...
                 'center', center );

%add callback to slider
add_callback(hSlider, {@sliderchange});

%link axes to slider
linkaxes(hSlider, hAx);

%-----------------------------------------------------------------------

%---create and populate toolbar-----------------------------------------
%in: hFig, cmdline, javacomp, ?behav_line, ?activecell_line, ?nspike_line
%out: T
function T = createtoolbar( hFig, cmdline, javacomp, plotobj, tooltips)

%create toolbar
tb = uitoolbar( 'Parent', hFig  );

%create toolbar item to show/hide command line
T = uitoggletool(tb, 'ClickedCallback', @(h,e) set(cmdline, 'Visible', ~get(cmdline,'Visible')), 'State', 'on', ...
             'TooltipString', 'show/hide command line', 'CData', repmat( reshape( [0.8 ...
                    1 0.8], [1 1 3] ), 20, 20 ));

%create toolbar item to show/hide options
T(2) = uitoggletool(tb, 'ClickedCallback', @(h,e) set(javacomp, 'Visible', ~get(javacomp,'Visible')), 'State', 'on', ...
             'TooltipString', 'show/hide controls', 'CData', repmat( reshape( [1 ...
                    0.8 0.8], [1 1 3] ), 20, 20 ), 'Separator', 'on');

T(3) = uitoggletool(tb, 'ClickedCallback', {@showhideactivity, hFig}, 'State', 'on', ...
             'TooltipString', 'show/hide activity', 'CData', repmat( reshape( [0.2 ...
                    0.2 1], [1 1 3] ), 20, 20 ), 'Separator', 'on');
T(4) = uitoggletool(tb, 'ClickedCallback', {@showhideradon, hFig}, 'State', 'off', ...
             'TooltipString', 'show/hide radon', 'CData', repmat( reshape( [0.4 ...
                    0.4 1], [1 1 3] ), 20, 20 ));
T(5) = uitoggletool(tb, 'ClickedCallback', {@showhideregression, hFig}, 'State', 'off', ...
             'TooltipString', 'show/hide regression', 'CData', repmat( reshape( [0.6 ...
                    0.6 1], [1 1 3] ), 20, 20 ));


for k= 1:numel(plotobj)
  
  T(end+1) = uitoggletool(tb, 'ClickedCallback', {@showhideobj, plotobj(k)}, 'State', 'on', ...
                          'TooltipString', tooltips{k}, ...
                          'CData', repmat( reshape( [0.2 0.2 1], [1 1 3] ), 20, 20 ), ...
                          'Separator', 'on');
end

T(9) = uitoggletool(tb, 'ClickedCallback', {@showhideradonannotation, hFig}, 'State', 'on', ...
                    'TooltipString', 'show/hide radon annotations', 'CData', repmat( reshape( [0.2 ...
                    0.2 1], [1 1 3] ), 20, 20 ), 'Separator', 'on');

%-----------------------------------------------------------------------

%---create reconstruction engine option dialog--------------------------
%in: reconstruction_engine, hFig
%out:

function [tab, tablemodels, table, s] = reconstruction_optionsdlg( engine, hFig )

import javax.swing.*

tablemodels = engine2javatable( engine, [], 1:4 );

tab = JTabbedPane();

grid = execute_core(engine,{'grid'}) + fkgrid( {'l', [0 1], 'time' });
state = struct( 'x', ndims(grid), 'y', 1, 'z', 0, ...
                'slice_index', ones(1, ndims(grid)), ...
                'slice_index2', min( ones(1,ndims(grid))+1, size(grid) ), ...
                'slice_index3', min( ones(1,ndims(grid))+2, size(grid) ), ...
                'slice_method', {repmat({'slice'}, ndims(grid), 1)} );

s = slicerui(grid, state);
add_callback(s, {@slicerchange, hFig});
tab.addTab('slicer', getPanel(s));

for k=1:numel(tablemodels)
  set(tablemodels(k).table, 'TableChangedCallback', {@optionchange, ...
                      tablemodels(k).name, hFig, 'engine'});
  table(k) = JTable( tablemodels(k).table ); %#ok
  scroll = JScrollPane( table(k) );
  tab.addTab(tablemodels(k).name, scroll);
end


%-----------------------------------------------------------------------

%---create radon engine option dialog-----------------------------------
%in:
%out:

function [tab, tablemodels, table] = radon_optionsdlg( engine, hFig )

import javax.swing.*

tablemodels = engine2javatable( engine, [], 1:4 );

tab = JTabbedPane();

for k=1:numel(tablemodels)
  set(tablemodels(k).table, 'TableChangedCallback', {@optionchange, ...
                      tablemodels(k).name, hFig, 'engine_radon'});
  table(k) = JTable( tablemodels(k).table ); %#ok
  scroll = JScrollPane( table(k) );
  tab.addTab(tablemodels(k).name, scroll);
end

%-----------------------------------------------------------------------

%---create regression engine option dialog------------------------------
%in:
%out:

function [tab, tablemodels, table] = regression_optionsdlg(engine, hFig)

import javax.swing.*

tablemodels = engine2javatable( engine, [], 1:2 );

tab = JTabbedPane();

for k=1:numel(tablemodels)
  set(tablemodels(k).table, 'TableChangedCallback', {@optionchange, ...
                      tablemodels(k).name, hFig, 'engine_regression'});
  table(k) = JTable( tablemodels(k).table ); %#ok
  scroll = JScrollPane( table(k) );
  tab.addTab(tablemodels(k).name, scroll);
end

%-----------------------------------------------------------------------

%---create option dialog bar--------------------------------------------
%in:
%out:

function [javacomp, tabs, tablemodels, tables, slicerobj] = create_optionsdlg( engines, hFig )

import javax.swing.*

options_panel = JPanel();
options_panel.setLayout( BoxLayout( options_panel, 3 ) );
options_panel.setPreferredSize(java.awt.Dimension(350,200));

[tabs.reconstruction, tablemodels.reconstruction, tables.reconstruction, slicerobj] = reconstruction_optionsdlg( engines.reconstruct_engine, hFig );

options_panel.add( tabs.reconstruction );

if ~isempty( engines.radon_engine )
  [tabs.radon, tablemodels.radon, tables.radon] = radon_optionsdlg( engines.radon_engine, hFig );
  options_panel.add( tabs.radon );
end

if ~isempty( engines.regression_engine )
  [tabs.regression, tablemodels.regression, tables.regression] = regression_optionsdlg( engines.regression_engine, hFig );
  options_panel.add( tabs.regression );
end

javacomp = javacomponent(options_panel, java.awt.BorderLayout.EAST, hFig );


%-----------------------------------------------------------------------

%---create axes and plot objects----------------------------------------
%in:
%out:

function [hAx, hImg, hLines]=createplots(hFig, plotlayout,hash)

hAx = plotlayout.childmatrix;

%%hImg = image([], 'Parent', hAx(1,1,1), 'CDataMapping', 'scaled');
hImg = surface( [],[],[],[], 'EdgeColor', 'none', 'FaceColor', 'flat', 'Parent', hAx(1,1,1));

set( hAx(1,1,1), 'CLim', [0 1], 'CLimMode', 'manual', 'XColor', [1 1 1], ...
             'YColor', [1 1 1], 'TickDir', 'out', 'Box', 'off' );

hImg(2) = image([], 'Parent', hAx(2,1,1), 'CDataMapping', 'scaled');

set(hAx(2,1,1), 'CLim', [0 1], 'CLimMode', 'auto', 'XColor', [1 1 1], 'YColor', ...
            [1 1 1], 'TickDir', 'out', 'Box', 'off', 'XTick', [], 'Position', [0.1300 0.1100 0.7750 0.8150] );

set(hAx(2,1,2), 'YAxisLocation', 'right', ...
                'Box', 'off', 'Color', 'none', 'XColor', [1 1 1], 'YColor', ...
                [1 1 1], 'TickDir', 'out', 'Position', [0.1300 0.1100 0.7750 0.8150]);

hImg(3) = image([], 'Parent', hAx(3,1,1), 'CDataMapping', 'scaled');
set(hAx(3,1,1), 'CLimMode', 'auto', 'XColor', [1 1 1], 'YColor', ...
            [1 1 1], 'TickDir', 'out', 'Box', 'off'  );

set(hAx(4,1,1), 'YLim', [0 1], 'XColor', [1 1 1], 'YColor', ...
                [1 1 1], 'TickDir', 'out', 'Box', 'off', 'Position', [0.1300 0.1100 0.7750 0.8150]  );

set(hAx(4,1,2), 'CLimMode', 'auto', 'XColor', [1 1 1], 'YColor', ...
            [1 1 1], 'XTick', [], 'Box', 'off', 'Color','none', 'YAxisLocation', 'right', 'Position', [0.1300 0.1100 0.7750 0.8150]  );

hLines.behav_line = line(0,0,'parent',hAx(1,1,1));
hLines.activecells_line = line(0,0,'parent', hAx(2,1,1));
hLines.ncells_line = line(0,0,'parent',hAx(2,1,2));

hLines.radonpeaks_line = line(0,0,'parent', hAx(3,1,1), 'LineStyle', 'none', 'Marker', 'o');

%enable axes interaction
delete( hAx([1 3],1,2) );

scroll_zoom( [hAx(1,1,1) hAx(2,1,2)], 'modifier', 1, 'axis', 'x');
scroll_pan( [hAx(1,1,1) hAx(2,1,2)], 'modifier', 2, 'axis', 'x');
ruler(hAx(1,1,1));
tab_axes(hFig);

hLines.radon_line = line(0,0,'parent', hAx(1) );

enable_events( [hAx(3,1,1) hAx(4,1,2)] )

add_callback( hAx(3,1,1), 'MyButtonDownFcn', {@drawradonline, hLines.radon_line,hash} )
add_callback( hAx(3,1,1), 'MyDragFcn', {@drawradonline, hLines.radon_line,hash} )
add_callback( hAx(3,1,1), 'MyButtonUpFcn', {@hideradonline, hLines.radon_line} );

hLines.regression_line = line(0,0,'parent',hAx(1), 'Color', [0.5 1 0.5] );

add_callback( hAx(4,1,2), 'MyButtonDownFcn', {@drawregressionline, hash} )
add_callback( hAx(4,1,2), 'MyDragFcn', {@drawregressionline, hash} )
add_callback( hAx(4,1,2), 'MyButtonUpFcn', {@hideregressionline, hash} );

hLines.r2_line = line(0,0,'parent', hAx(4,1,1));
hLines.slope_line = line(0,0,'parent', hAx(4,1,2));

%-----------------------------------------------------------------------


function showhideradonannotation(hObj, event, hFig) %#ok

h = getappdata(hFig, 'replay');
T = h.get('toggles');

if strcmp( get(T(4), 'State'), 'off')
  %radon is hidden
  return
end

H1 = h.get('peaks_radon');
H2 = h.get('ellipses_radon');
H3 = h.get('lines_radon');
H4 = h.get('text_radon');

if strcmp( get(hObj, 'State'), 'on')
  %show
  set(H1, 'Visible', 'on');
  set(H2, 'Visible', 'on');
  set(H3, 'Visible', 'on');
  set(H4, 'Visible', 'on');
else
  set(H1, 'Visible', 'off');
  set(H2, 'Visible', 'off');
  set(H3, 'Visible', 'off');
  set(H4, 'Visible', 'off');
end  
  

function showhideactivity(hObj, event, hFig) %#ok

h = getappdata(hFig, 'replay');
L = h.get('axeslayout');
height = get(L, 'height');
height(2) = ~height(2);
set(L, 'height', height);

if height(2)
  updateactivityview(h);
end

function showhideradon(hObj, event, hFig) %#ok

h = getappdata(hFig, 'replay');
L = h.get('axeslayout');
height = get(L, 'height');
height(3) = ~height(3);
set(L, 'height', height);

if height(3)
  %make visible
  T = h.get('toggles');
  H1 = h.get('peaks_radon');
  H2 = h.get('ellipses_radon');
  H3 = h.get('lines_radon');
  H4 = h.get('text_radon');
  if strcmp( get(T(9), 'State'), 'on')
    set(H1, 'Visible', 'on');
    set(H2, 'Visible', 'on');
    set(H3, 'Visible', 'on');
    set(H4, 'Visible', 'on');
  else
    set(H1, 'Visible', 'off');
    set(H2, 'Visible', 'off');
    set(H3, 'Visible', 'off');
    set(H4, 'Visible', 'off');
  end
  updateradonview(h);
else
  %hide
  H3 = h.get('lines_radon');
  set(H3, 'Visible', 'off');
end

function showhideregression(hObj, event, hFig) %#ok
h = getappdata(hFig, 'replay');
L = h.get('axeslayout');
height = get(L, 'height');
height(4) = ~height(4);
set(L, 'height', height);
if height(4)
  updateregressionview(h);
end

function showhideobj(h,e,hObj) %#ok

if strcmp( get(hObj, 'Visible'), 'on' )
  set(hObj, 'Visible', 'off');
else
  set(hObj, 'Visible', 'on');
end

function showhidepanel(h,e, L, row) %#ok

height = get(L, 'height');

height(row) = ~height(row);

set(L, 'height', height);


function showhiderow(h,e, L, row, defheight) %#ok

height = get(L, 'height');

if height(row)==0
  height(row)=defheight;
else
  height(row) = 0;
end

set(L, 'height', height);


function showhidecol(h,e, L, col, defwidth) %#ok

width = get(L, 'width');

if width(col)==0
  width(col)=defwidth;
else
  width(col) = 0;
end

set(L, 'width', width);


function optionchange( h, event, option, hFig, engine_name ) %#ok
  
row = event.getFirstRow();
src = event.getSource();

parm = src.getValueAt(row, 0);
val = src.getValueAt(row,1);
val = strrep(val, '''', '''''');

h = getappdata(hFig, 'replay');
engine = h.get(engine_name); %#ok

try
  eval( [option '.' parm '=''' val ''';'] );
catch
  %revert to saved option
  eval( ['val = ' option '.' parm ';'] );
  updateParameter( src, row, validate(val) );
  tables = h.get('tables_reconstruction');
  tablemodels = h.get('tablemodels_reconstruction');
  idx = find( strcmp( option, {tablemodels.name} ) );
  tables(idx).tableChanged( javax.swing.event.TableModelEvent( tablemodels(idx).table, row ) );
end

  
function updateviews(h) %h is hash

T = h.get('toggles');

%update estimateview
updateestimateview(h)

%update activityview
if strcmp( get(T(3), 'state'), 'on' )
  updateactivityview(h);
end

%update radonview
if strcmp( get(T(4), 'state'), 'on' )
  updateradonview(h);
end

%update regressionview
if strcmp( get(T(5), 'state'), 'on' )
  updateregressionview(h)
end


function sliderchange(hS, ctr, wsz)
%recalculate with new viewport
%call updateviews

S = slider(hS);
hFig = ancestor( S.parent, 'figure' );
h = getappdata(hFig, 'replay');

e = h.get('engine'); %#ok

e.viewport = ctr + wsz.*[-0.5 0.5];

%update slicer gui
%s = h.get('slicer');
%[bins, grid] = execute_core(e, {'bins', 'grid'});

%b = e.bin.binsize.*(1-e.bin.overlap);

%m = mean(bins, 2);

%updategrid(s, grid + fkgrid( {'l', (m(1)-0.5*b):b:(m(end)+0.5*b) , 'time' }) );



function figdelete(hFig, e) %#ok

h = getappdata( hFig, 'replay' );

e = h.get('engine');

remove_callback(e);

h.clear;
h.delete;


%delete( A.L );


function enginechange(hE, event, hFig, engine) %#ok
%recalc
%call updateviews

h = getappdata(hFig, 'replay');
tablemodels = h.get(['tablemodels_' engine]);
tables = h.get(['tables_' engine]);

%update option tables
idx = find( strcmp( event.engine, {tablemodels.name} ) );
if ~isempty(idx)
  p = cellstr( char( getParameters( tablemodels(idx).table ) ) );

  for k=1:numel(event.slots_in)
    ii = find( strcmp( event.slots_in{k}, p ) );
    if isempty(ii)
      continue
    end
    updateParameter( tablemodels(idx).table, ii-1, validate(event.values{k}) );
    tables(idx).tableChanged( javax.swing.event.TableModelEvent( tablemodels(idx).table, ii-1 ) );
  end
end

T = h.get('toggles');

switch engine
 case 'reconstruction'

  %update slicer grid
  e = h.get('engine');
  s = h.get('slicer');
  [bins, grid] = execute_core(e, {'bins', 'grid'});
  
  b = e.bin.binsize.*(1-e.bin.overlap);
  m = mean(bins, 2);

  updategrid(s, grid + fkgrid( {'l', (m(1)-0.5*b):b:(m(end)+0.5*b) , 'time' }) );  

  %update estimateview
  updateestimateview(h)

  %set inputs of radon engine
  updateradonengine(h);
  
  %set inputs of regression engine
  updateregressengine(h);
  
  %update activityview
  if strcmp( get(T(3), 'state'), 'on' )
    updateactivityview(h);
  end
  
 case 'radon'
  if strcmp( get(T(4), 'state'), 'on' )
    updateradonview(h);
  end
  
 case 'regression'
  if strcmp( get(T(5), 'state'), 'on' )
    updateregressionview(h)
  end
  
end


function updateestimateview(h)
%get estimate
engine = h.get('engine');
[estimate, behavior] = execute_core(engine, {'estimate', 'behavior'});

%get slicer options
s = h.get('slicer');
state = getState(s);
grid = getGrid(s);

%call slice2d
m = slice2d( estimate, state );

%draw image
img = h.get('image_estimate');

if strcmp( names(grid,state.x), 'time' )
  %assume x dimension is always time (thus a linear grid)
  cx = edges(grid,state.x);  
else
  x_iscategorical = iscategorical( grid, state.x );
  if x_iscategorical
    %%cy = 1:size(grid,state.y);
    cx = 0:size(grid,state.x);
  else
    %%cy = centers(grid, state.y);
    cx = edges(grid, state.x);
  end
end
  
y_iscategorical = iscategorical( grid, state.y );
if y_iscategorical
  %%cy = 1:size(grid,state.y);
  cy = 0:size(grid,state.y);
else
  %%cy = centers(grid, state.y);
  cy = edges(grid, state.y);
end

%%set(img, 'CData', m, 'XData', centers(grid, state.x), 'YData', cy );

set(img, 'XData', cx, 'YData', cy, 'ZData', zeros(numel(cy), numel(cx)), ...
         'CData', m );

%set axis properties
hAx = h.get('axes');
%set(hAx(1,1,1),'CLim', [0 max( 0.1, max(m(:)) )] )
set(hAx(1,1,1),'CLim', [0 1] )

set(hAx(1,1,1), 'YLim', cy([1 end]));
if ~strcmp( names(grid,state.x), 'time' )
  set(hAx(1,1,1), 'XLim', cx([1 end]));
  if x_iscategorical
    set(hAx(1,1,1), 'XTick', cx, 'XTickLabel', labels(grid, state.x) );
  end
end

if y_iscategorical
  set(hAx(1,1,1), 'YTick', cy, 'YTickLabel', labels(grid, state.y) );
end

xlabel(hAx(1,1,1), names(grid,state.x) );
ylabel(hAx(1,1,1), names(grid,state.y) );


%draw behavior
hLine = h.get('lines_estimate');
hSlider = h.get('slider');

%xl = get(hAx(1,1,1), 'XLim');
xl = get(hSlider,'center') + [-.5 .5].*get(hSlider,'windowsize');

idx = find( behavior.time>=xl(1), 1):find(behavior.time<=xl(2),1, 'last');

if ~strcmp(names(grid,state.x), 'time' )
  if x_iscategorical
    xdata = bin( grid, behavior.variables(idx, state.x), state.x );
  else
    xdata = behavior.variables(idx,state.x);
  end
else
  xdata = behavior.time(idx);
end
if y_iscategorical
  ydata = bin( grid, behavior.variables(idx, state.y), state.y );
else
  ydata = behavior.variables(idx,state.y);
end

set(hLine, 'XData', xdata, 'YData', ydata );

function updateactivityview(h)
%get activity
engine = h.get('engine');
[bins, activity] = execute_core(engine, {'bins', 'spikecount'});

%draw image
hAx = h.get('axes');
img = h.get('image_activity');

set( img, 'CData', activity, 'XData', [mean(bins(1,:)) mean(bins(end,:))], ...
          'YData', [1 size(activity,1)]);
set(hAx(2,1,1), 'YLim', [1 size(activity,1)]);

xlabel(hAx(2,1,2), 'time');
ylabel(hAx(2,1,1), 'cell # / # cells');
ylabel(hAx(2,1,2), '# spikes');

hLine = h.get('lines_activity');

set( hLine(1), 'XData', mean(bins, 2), 'YData', sum( activity>0 ), 'Color', [0 1 1] );
set( hLine(2), 'XData', mean(bins, 2), 'YData', sum( activity ), 'Color', [0 0 1]);


function updateradonview(h)
%get estimate image
hAx = h.get('axes');
img = h.get('image_radon');
%img_source = h.get('image_estimate');
%m = get( img_source, 'CData' );

%if rgb image -> max operation
%if ndims(m)==3 && size(m,3)>1
%  m = max( m, [], 3);
%end

%do radon transform
e = h.get('engine_radon');
%s = h.get('slicer');
%state = getState(s);
%grid = getGrid(s);
%delta = deltas(grid, [state.x state.y]);
%ctrs = centers( grid, [state.x state.y] );
%[r, theta, rho, pks, projections, segments] = e('matrix',m', 'dx',delta(1), 'dy',delta(2), 'origin',[ctrs{1}(1) ctrs{2}(1)]);

[r, theta, rho, pks, proj, segments] = execute_core(e, {'radon', 'theta', 'rho', ...
                    'peaks', 'projections', 'segments'});


%draw image
%set(img, 'CData', r, 'XData', rho + mean(get(hAx(3,1,1), 'XLim')),
%'YData', theta);
set(img, 'CData', r, 'XData', rho, 'YData', theta);
set( hAx(3,1,1), 'YLim', theta([1 end]), 'XLim', rho([1 end]));

ylabel( hAx(3,1,1), 'theta');
xlabel( hAx(3,1,1), 'rho');

%xo = mean(get(hAx(3,1,1),'XLim'));

%draw lines and peaks
hLine = h.get('peaks_radon');
if size(pks,1)>0
  set(hLine, 'XData', pks(:,2), 'YData', pks(:,1)); %+xo
else
  set(hLine, 'XData', [], 'YData', []);
end

T = h.get('toggles');
isvisible = get(T(9), 'State');

hLine = h.get('ellipses_radon');
delete( hLine(ishandle(hLine)) );
hLine = [];
el = e.peaks.ellipse;
for k=1:size(pks,1)
  hLine(k) = rectangle('Position', [pks(k,2)-el(1), pks(k,1)-el(2), el(1)*2, ...
                      el(2)*2], 'Curvature', [1 1], 'Parent', hAx(3,1,1), ...
                       'EdgeColor', [0 1 1], 'Visible', isvisible);
end
h.put('ellipses_radon', hLine);

hLine = h.get('lines_radon');
delete( hLine(ishandle(hLine)) );
hLine = [];

%yl = get(hAx(1,1,1), 'YLim');

for k=1:size(pks,1)
  %x = -(yl-mean(yl)).*tan(pks(k,1)) + pks(k,2);
  %hLine(k) = line( x, yl, 'Parent', hAx(1,1,1), 'Visible', isvisible);
  hLine(end+1) = line( proj(k).xlim, proj(k).ylim, 'Visible', isvisible, ...
                       'Parent', hAx(1,1,1), 'Color', [1 0.9 0.7], ...
                       'LineStyle', '- -');
  for l = 1:numel(segments{k})
    hLine(end+1) = line( segments{k}(l).xlim, segments{k}(l).ylim, 'Visible', ...
                         isvisible, 'Parent', hAx(1,1,1), 'Color', [0 1 0], 'LineWidth', 3  );
  end
end
h.put('lines_radon', hLine);


hText=h.get('text_radon');
delete( hText(ishandle(hText)) );
hText = [];

for k=1:size(pks,1)
  hText(k) = text(pks(k,2), pks(k,1), num2str(pks(k,3)), 'Parent', ...
                  hAx(3,1,1), 'HorizontalAlignment', 'center', 'VerticalAlignment', ...
                  'top', 'Color', [0 1 0], 'Visible', isvisible);
end
h.put('text_radon', hText);

function updateregressionview(h)
hAx = h.get('axes');
e = h.get('engine_regression');

[x, B, r] = execute_core(e, {'x', 'coefficients' 'r'});

%draw line/image
x = mean(x,2);
hLine = h.get('lines_regression');
set(hLine(1), 'XData', x, 'YData', r);
set(hLine(2), 'XData', x, 'YData', B(:,2), 'Color', [1 0.5 1])

xlabel( hAx(4,1,1), 'time');
ylabel( hAx(4,1,1), 'R-squared');
ylabel( hAx(4,1,2), 'slope');


function estimateviewchange()
%hide/show behavior line

function radonviewchange()
%hide/show radon peaks/lines

function regressionviewchange()
%hide/show regression peaks/lines


function result=drawradonline(hObj, event, hLine, h) %#ok

if bitand(event.Modifiers,1)
  result = false;
  return
end

rho = event.HitPoint(1);
theta = event.HitPoint(2);

e = h.get('engine_radon');

%local image centers
ctrx = e.dx.*(size(e.matrix,2)-1)/2;
ctry = e.dy.*(size(e.matrix,1)-1)/2;

if e.rho_x
  rho = rho * cos(theta);
end

%intersect lines with local bounding box
[px, py] = lineboxintersect( [theta rho], [-ctrx ctrx -ctry ctry] );

%x = -(yl-mean(yl)).*tan(theta) + rho; %(rho-mean(xl))./(cos(theta).^2) + mean(xl)

set( hLine, 'XData', px+ctrx+e.origin(1), 'YData', py+ctry+e.origin(2), 'Visible', 'on');

result = true;

function hideradonline(hObj, event, hLine) %#ok

set(hLine, 'Visible', 'off');


function result = drawregressionline(hObj, event, h) %#ok

if bitand(event.Modifiers,1)
  result = false;
  return
end

e = h.get('engine_regression');
L = h.get('regress_line');
[x, B] = execute_core( e, {'x','coefficients'} );

if ~isempty(x)
  idx = nearestpoint(event.HitPoint(1), mean(x,2));
  set(L, 'XData', x(idx,:), 'YData', B(idx,1) + B(idx,2).*x(idx,:), 'Visible', 'on');
end

result = true;

function hideregressionline(hObj, event, h) %#ok

L = h.get('regress_line');
set(L, 'visible', 'off');

function slicerchange(hObj, state, hFig) %#ok
%updateestimateview
h = getappdata(hFig, 'replay');

hSlicer = h.get('slicer');
slicergrid = getGrid( hSlicer );
hSlider = h.get('slider');
hAx = h.get('axes');

if strcmp( names(slicergrid,state.x), 'time' )
  linkaxes( hSlider, hAx(1,1,1) );
  scroll_zoom( hAx(1,1,1), 'modifier', 1, 'axis', 'x');  
  scroll_pan( hAx(1,1,1), 'modifier', 2, 'axis', 'x');
else
  unlinkaxes( hSlider, hAx(1,1,1) );
  scroll_zoom( hAx(1,1,1), 'off');  
  scroll_pan( hAx(1,1,1), 'off');    
end

%update estimateview
updateestimateview(h)

%set inputs of radon engine
updateradonengine(h);
  
  
function val = validate(val)

if isnumeric(val) || islogical(val)
  if isempty(val)
    val = '[]';
  else
    val = mat2str(val);
  end
elseif isstruct(val)
  val = struct2str(val);
elseif iscell(val)
  val = cell2str(val);
elseif isa(val, 'function_handle')
  val = func2str(val );
elseif ischar(val)
  %val = val;
else
  val = NaN;
end


function updateradonengine(h)
img_source = h.get('image_estimate');
m = get( img_source, 'CData' );

%if rgb image -> max operation
if ndims(m)==3 && size(m,3)>1
  m = max( m, [], 3);
end

e = h.get('engine_radon');
s = h.get('slicer');
state = getState(s);
grid = getGrid(s);
delta = deltas(grid, [state.x state.y]);
ctrs = centers( grid, [state.x state.y] );
set( e, 'matrix', m, 'dx', delta(1), 'dy', delta(2), 'origin', [ctrs{1}(1) ...
                    ctrs{2}(1)]);

function updateregressengine(h)
%get estimate image
img_source = h.get('image_estimate');
m = get( img_source, 'CData' );

%if rgb image -> max operation
if ndims(m)==3 && size(m,3)>1
  m = max( m, [], 3);
end

%do regression
e = h.get('engine_regression');
s = h.get('slicer');
state = getState(s);
grid = getGrid(s);
grid = struct2cell(grid([state.x state.y]));
set(e, 'matrix', m, 'grid', fkgrid( grid(:,:,1), grid(:,:,2) ) );