function [jc, hc] = javacommandline( hParent, fcn )
%JAVACOMMANDLINE custom command line (java component)
%
%  [jc,hc]=JAVACOMMANDLINE creates a new command line and returns the
%  handle of the java component jc and the handle of the graphics
%  container hc. Commands are executed in the base workspace.
%
%  [...]=JAVACOMMANDLINE(h) create command line in figure with handle h.
%
%  [...]=JAVACOMMANDLINE(h,fcn) the command is passed to the custom
%  function. The function should return a character array with the result
%  that will be displayed.
%

if nargin<1 || isempty(hParent)
  hParent = gcf;
elseif ~ishandle(hParent) || ~any(strcmp(get(hParent, 'type'), 'figure') )
  error('javacommandline:invalidHandle', 'Invalid handle');
  
end

if nargin<2 || isempty(fcn)
  fcn = @defaulthandler;
elseif ~isa(fcn, 'function_handle')
  error('javacommandline:invalidFunction', 'Invalid function handle');
end

import javax.swing.*
import java.awt.*

panel_left = JPanel();
panel_left.setLayout( BoxLayout( panel_left, 3 ) );

panel_right = JPanel();
panel_right.setLayout( BoxLayout( panel_right, 3 ) );

textfield = JTextField();
textfield.setPreferredSize(Dimension(100,20));
textfield.setToolTipText( 'command input' );

list = JList(DefaultListModel());
list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
list.setVisibleRowCount(-1);
list.setToolTipText( 'history' );

listscrollpane = JScrollPane( list );
listscrollpane.setVerticalScrollBarPolicy( listscrollpane.VERTICAL_SCROLLBAR_ALWAYS);
listscrollpane.setPreferredSize( Dimension(100,80) );

panel_left.add( textfield );
panel_left.add( listscrollpane );

textpane = JTextPane();
textpane.setToolTipText( 'command output' );

scrollpane = JScrollPane( textpane );
scrollpane.setVerticalScrollBarPolicy( scrollpane.VERTICAL_SCROLLBAR_ALWAYS );
scrollpane.setPreferredSize( Dimension(100,100) );

textpane.setEditable(false);
textpane.setEnabled(false);

panel_right.add( scrollpane );

split_panel = JSplitPane(JSplitPane.HORIZONTAL_SPLIT, panel_left, panel_right);

doc = textpane.getDocument();

%set styles
style = doc.addStyle('command', []);
text.StyleConstants.setForeground(style, java.awt.Color(1,0,0));

style = doc.addStyle('prompt', []);
text.StyleConstants.setForeground(style, java.awt.Color(0.5,0,0));
text.StyleConstants.setItalic(style, true);

style = doc.addStyle('result', []);
text.StyleConstants.setForeground(style, java.awt.Color(0.5, 0.5, 1));
text.StyleConstants.setFontSize(style, 12);

%[jc, hc] = javacomponent( scrollpane, [0 0 100 100], ancestor(hParent, 'figure')); %#ok
%set(hc, 'Parent', hPanels_main(1,2), 'Units', 'normalized', 'Position', ...
%        [0 0 1 1] );

[jc, hc] = javacomponent( split_panel, java.awt.BorderLayout.SOUTH, hParent );

set( textfield, 'ActionPerformedCallback', {@cmdhandler, hParent} );
set( list, 'MouseClickedCallback', {@historyhandler, hParent} );

%keep references around
setappdata(hParent, 'commandline', struct( 'panel', split_panel, ...
                                           'command', textfield, ...
                                           'history', list, ...
                                           'result', textpane, ...
                                           'historyscroll', listscrollpane, ...
                                           'resultscroll', scrollpane, ...
                                           'fcn', fcn, ...
                                           'resultdoc', doc) );


function result = defaulthandler(cmd)
%evaluate in base workspace

try
  cmd = strrep( cmd, '''', '''''');
  result = evalin('base', ['evalc(''' cmd ''')']);
catch
  result = lasterr;
end

function historyhandler(hObj, event, hFig) %#ok

cmdline = getappdata(hFig, 'commandline');

if get(event, 'ClickCount')>1
  
  cmdhandler(cmdline.command, [],hFig);
  
else

  history = get(hObj, 'SelectedValue');
  
  if ~isempty(history)
    set(cmdline.command, 'Text', history);
  end
  
end


function cmdhandler(hObj, event, hFig) %#ok
%get command and empty command line
%add command to result
%add command to history
%execute fcn to evalutae command and get result
%add result to result

cmdline = getappdata(hFig, 'commandline');

%get command
cmd = get(hObj, 'Text');

if isempty(cmd)
  return
end

%clear command line
set(hObj, 'Text', '');

%add to history
awtinvoke(cmdline.history.getModel, 'addElement', java.lang.String(cmd));
awtinvoke(cmdline.history, 'setSelectedIndex', cmdline.history.getModel().getSize()-1 );

%scroll to the bottom
scrollbar = cmdline.historyscroll.getVerticalScrollBar();
scrollbar.updateUI();
awtinvoke(scrollbar, 'setValue', scrollbar.getMaximum );

%add to result
cmdline.resultdoc.insertString( cmdline.resultdoc.getLength(), 'command: ', cmdline.resultdoc.getStyle('prompt') );
cmdline.resultdoc.insertString( cmdline.resultdoc.getLength(), sprintf('%s\n',cmd), cmdline.resultdoc.getStyle('command'));

%evaluate command
try
  result = cmdline.fcn(cmd);
catch
  result = sprintf('ERROR EVALUATING COMMAND');
end

%remove empty lines
if ischar(result)
  result = strread( result, '%s', 'delimiter', sprintf('\n') );
end
idx = cellfun('isempty', result);
result(idx)=[];

%print results
cmdline.resultdoc.insertString( cmdline.resultdoc.getLength(), sprintf('%s\n', result{:}), cmdline.resultdoc.getStyle('result'));

%scroll to the bottom
scrollbar = cmdline.resultscroll.getVerticalScrollBar();
scrollbar.updateUI();
awtinvoke(scrollbar, 'setValue', scrollbar.getMaximum );

requestFocusInWindow( cmdline.command );
