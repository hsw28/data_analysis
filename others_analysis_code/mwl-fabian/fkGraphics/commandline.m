function commandline( hParent, fcn )
%COMMANDLINE custom command line in figure
%
%  COMMANDLINE create a command line in a  new figure. All commands are
%  executed in the base workspace.
%
%  COMMANDLINE(h) create command line in figure or uipanel with handle
%  h.
%
%  COMMANDLINE(h,fcn) the command is passed to the custom function. The
%  function should return a character array with the result that will be
%  displayed.
%


if nargin<1 || isempty(hParent)
  hParent = gcf;
elseif ~ishandle(hParent) || ~any(strcmp(get(hParent, 'type'), {'figure', ...
                      'uipanel'}) )
  error('commandline:invalidHandle', 'Invalid handle');
  
end

if nargin<2 || isempty(fcn)
  fcn = @defaulthandler;
elseif ~isa(fcn, 'function_handle')
  error('commandline:invalidFunction', 'Invalid function handle');
end

Lmain = layoutmanager( hParent, 1, 2, 'fcn', @uipanel, 'width', [1 2], 'argin', ...
                   {'BorderType', 'none', 'HitTest', 'off'} );

hPanels_main = Lmain.childmatrix;

Lsub = layoutmanager( hPanels_main(1,1), 2, 1, 'fcn', @uipanel, 'height', ...
                      [-1.5 1], 'argin', {'BorderType', 'none', 'HitTest', 'off'} );

hPanels_sub = Lsub.childmatrix;

cmdline = uicontrol('Parent', hPanels_sub(1,1), 'Style', 'edit', 'Units', ...
                    'normalized', 'Position', [0 0 1 1], 'HorizontalAlignment', ...
                    'left');

history = uicontrol('Parent', hPanels_sub(2,1), 'Style', 'listbox', 'Units', ...
                    'normalized', 'Position', [0 0 1 1]);

import javax.swing.*

textpane = JTextPane();
scrollpane = JScrollPane( textpane );
scrollpane.setVerticalScrollBarPolicy( scrollpane.VERTICAL_SCROLLBAR_ALWAYS );

textpane.setEditable(false);
textpane.setEnabled(false);

doc = textpane.getDocument();

%set styles
style = doc.addStyle('command', []);
text.StyleConstants.setForeground(style, java.awt.Color(1,0,0));

style = doc.addStyle('prompt', []);
text.StyleConstants.setForeground(style, java.awt.Color(0.5,0,0));
text.StyleConstants.setItalic(style, true);

style = doc.addStyle('result', []);
text.StyleConstants.setForeground(style, java.awt.Color(0.8, 0.8, 1));
text.StyleConstants.setFontSize(style, 12);

[jc, hc] = javacomponent( scrollpane, [0 0 100 100], ancestor(hParent, 'figure')); %#ok
set(hc, 'Parent', hPanels_main(1,2), 'Units', 'normalized', 'Position', ...
        [0 0 1 1] );


set( cmdline, 'Callback', {@cmdhandler, fcn, history, doc, scrollpane} );
set( history, 'Callback', {@historyhandler, cmdline} );


function result = defaulthandler(cmd)
%evaluate in base workspace

try
  cmd = strrep( cmd, '''', '''''');
  result = evalin('base', ['evalc(''' cmd ''')']);
catch
  result = lasterr;
end

function historyhandler(hObj, event, cmdline) %#ok

selection = get(hObj, 'Value');
history = get(hObj, 'String');

if ~isempty(selection) && numel(selection)==1
  set(cmdline, 'String', history{selection});
end


function cmdhandler(hObj, event, fcn, history, doc, scrollpane) %#ok
%get command and empty command line
%add command to result
%add command to history
%execute fcn to evalutae command and get result
%add result to result

%get command
cmd = get(hObj, 'String');

if isempty(cmd)
  return
end

%clear command line
set( hObj, 'String', '');

%add to history
cmd_history = get(history, 'String');
cmd_history = vertcat( cmd_history, {cmd} );
cmd_history = cmd_history(1:min(100,end));
set(history, 'String', cmd_history );

%add to result
doc.insertString( doc.getLength(), 'command: ', doc.getStyle('prompt') );
doc.insertString( doc.getLength(), sprintf('%s\n',cmd), doc.getStyle('command'));

%evaluate command
try
  result = fcn(cmd);
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
doc.insertString( doc.getLength(), sprintf('%s\n', result{:}), doc.getStyle('result'));

%scroll to the bottom
scrollbar = scrollpane.getVerticalScrollBar();
scrollbar.updateUI();
scrollbar.setValue( scrollbar.getMaximum );

set(history, 'Value', numel(cmd_history));
