function test_events()
%TEST_EVENTS test figure for event dispatch framework
%
%  TEST_EVENTS creates figure that will allow the user to explore the
%  event dispatching framework
%

%  Copyright (C) 2006 Fabian Kloosterman
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
%  Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 

%create figure with axes
hFig = event_dispatch('on');

hAx = axes('XLim', [0 1], 'YLim', [0 1], 'Parent', hFig);
hP = patch( [0.2 0.4 0.4 0.2], [0.2 0.2 0.5 0.5], [1 0 0], 'Parent', hAx );

%create text area for displaying events
import javax.swing.*

TxtArea = JTextPane();
TxtArea.setEditable(false);

a = javax.swing.text.SimpleAttributeSet();
javax.swing.text.StyleConstants.setLineSpacing( a, -0.25);
doc = TxtArea.getStyledDocument;
doc.setParagraphAttributes(0, doc.getLength(), a, false );

jc = javacomponent( JScrollPane( TxtArea ), 'East', hFig ); %#ok

d = java.awt.Dimension(400, 0);
jc.setPreferredSize(d);

drawnow;

%enable events
enable_events( [hFig hAx hP] );

%set callbacks
set_callbacks( hFig );
set_callbacks( hAx );
set_callbacks( hP );


  function set_callbacks( hObj )
  %SET_CALLBACKS setup callbacks for an object
    
  set( hObj, 'MyButtonDownFcn', {@handle_event, 'MyButtonDown'})
  set( hObj, 'MyButtonUpFcn', {@handle_event, 'MyButtonUp'})
  set( hObj, 'MyWheelMovedFcn', {@handle_event, 'MyWheelMoved'})
  %set( hObj, 'MyStartDragFcn', {@handle_event, 'MyStartDrag'})
  %set( hObj, 'MyStopDragFcn', {@handle_event, 'MyStopDrag'})
  set( hObj, 'MyKeyPressFcn', {@handle_event, 'MyKeyPress'})
  set( hObj, 'MyKeyReleaseFcn', {@handle_event, 'MyKeyRelease'})
  
  end


  function success = handle_event( hObj, eventdata, eventtype ) %#ok
  %HANDLE_EVENT print event information
  
  %information for key press/release type of events
  if ismember( eventtype, {'MyKeyPress','MyKeyRelease'})
    msg = sprintf('Event: %s - Callback Object: %s - Key Code: %s\n',eventtype,get(hObj,'Type'),num2str(eventdata.KeyCode));
  else  %information for every other type of event
    msg = sprintf(['Event: %s - Callback Object: %s - Button: %s\nHitObject: %s - HitPoint: ' ...
                   '%s\n'], eventtype, get(hObj,'Type'), num2str(eventdata.Button), get(eventdata.HitObject, 'Type'), ...
                  num2str(eventdata.HitPoint,'%.2f '));
  end
  
  %information specific to some events
  if ismember( eventtype , {'MyButtonDown', 'MyButtonUp', 'MyStartDrag', ...
                        'MyStopDrag'} )
    msg = [msg sprintf('ClickedObject: %s - ClickedPoint: %s\n', get(eventdata.HitObject,'Type'), ...
                       num2str(eventdata.ClickedPoint,'%.2f '))];
  end
  
  if ismember(eventtype , {'MyStartDrag','MyStopDrag'} )
    msg = [msg sprintf('DraggedPoint: %s\n', num2str(eventdata.HitPoint,'%.2f '))];
           
  end
  
  if ismember(eventtype, {'MyWheelMoved'})
    msg = [msg sprintf('WheelRotation: %.2f\n', ...
                       eventdata.WheelRotation)];
  end
  
  %prepend information to existing text
  msg = [msg sprintf('\n') char( TxtArea.getText() )];
  
  %print information
  TxtArea.setText( msg );
  
  %event succesfully handled
  success = true;
  
  end


end
