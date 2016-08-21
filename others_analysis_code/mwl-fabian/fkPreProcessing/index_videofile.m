function video_index = index_videofile( filename )
%INDEX_VIDEOFILE indexing of video file
%
%  vidx=INDEX_VIDEOFILE(filename) shows video image in new figure
%  and allows the user to browse the video frame-by-frame using the
%  mouse wheel. Pressing shift or control modifier keys will skip
%  2000 or 100 frames respectively. For each video frame the user
%  can save the real timestamp (in hh:mm:ss.ms) and thus create a
%  mapping between video time and real time.
%

%  Copyright 2007-2008 Fabian Kloosterman


%check arguments
if nargin<1 || isempty(filename)
  [filename, pathname] = uigetfile('*.*', 'Please select video file');
  if isequal(filename,0)
    return
  end
else
  [pathname, filename, extension]=fileparts(filename);
  filename = [filename extension];
end

%create video object
hVid = fkVideo.video( fullfile( pathname, filename ) );

current_frame = hVid.CurrentFrame;
current_img = hVid.Frame;

%preallocate index
video_index = sparse(1000,1);

%create figure
hFig = figure('NextPlot', 'new', 'Name', ['Processing video: ' filename], ...
              'toolbar', 'none', 'MenuBar', 'none', 'CloseRequestFcn', ...
              @close_main_figure, 'Color', [0.9 0.9 1], 'NumberTitle', ...
              'off', 'Colormap', gray(256));


%create ui
ui = struct();
layout_main_figure;

%define some constants
small_step = 1;
medium_step = 100;
large_step = 2000;

%initial image update
update_img();

%wait until user closes figure
waitfor(hFig)

video_index = [ find(video_index) full(video_index(find(video_index))) ]; %#ok

  function close_main_figure(hFig, eventdata) %#ok
  delete(hFig);
  end

  function layout_main_figure()
  %LAYOUT_MAIN_FIGURE create ui layout
  
  %constants
  cheight = 2;
  cwidth = 20;
  h = 7;
  
  %set initial figure position
  sz = get(0,'ScreenSize');
  set(hFig, 'Position', [sz(3)/4 sz(4)/4 sz(3)/2 sz(4)/2]);
  
  %create panels
  ui.panel = axismatrix( 1,2,'Parent', hFig, 'Fcn', @uipanel, 'YOffset', ...
                         1, 'XOffset', 2, 'YSpacing', 1, 'XSpacing', 2, ...
                         'Width', [1 -2*cwidth], 'ArgIn', {'BorderType', 'none'});  
  ui.panel(3) = axismatrix( 1,1, 'Parent', ui.panel(2), 'Fcn', @uipanel, ...
                           'YOffset', 1, 'XOffset', 0, 'YSpacing', 1, ...
                           'XSpacing', 0, 'Width', -2*cwidth, 'Height', -(4+h)*cheight, 'ArgIn', ...
                            {'BorderType', 'none'} );
  
  %create axes
  ui.axis = axes('Parent', ui.panel(1), 'Units', 'normalized');
  
  %enable event dispatching
  event_dispatch(hFig);
  enable_events( ui.axis );
  
  %add callbacks
  add_callback( ui.axis, 'MyWheelMovedFcn', @wheelfcn );
  add_callback( hFig, 'MyKeyPressFcn', @keypressfcn );
  
  %add controls
  ui.help = uicontrol('Parent', ui.panel(3), 'Units', 'characters', 'Style', 'text',...
                      'Position', [0 0 2*cwidth h*cheight], 'String', ...
                      { 'Use left/right cursor keys to go to previous/next video frame.', ... 
                      'Use pgup/pgdwn keys to move by N frames (where N is set above).', ... 
                      'Mouse scroll wheel can be used instead of left/right cursor keys.', ...
                      'Shift + mouse scroll wheel has same function as pgup/pgdwn.'}, ...
                      'FontAngle', 'italic', 'HorizontalAlignment', 'left', ...
                      'ForegroundColor', [0 0 1]);
  
  ui.button = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                        'Position', [0 h*cheight 2*cwidth cheight], 'String', ...
                        'save timestamp', 'Callback', @savetimestamp);
  
  ui.index = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                       'Style', 'edit', 'Position', [0 (h+1)*cheight 2*cwidth ...
                      cheight], 'String', '');
  
  ui.frame = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                       'Style', 'text', 'Position', [0 (h+2)*cheight 2*cwidth ...
                      cheight], 'String', '1');
  
  
  
  end

  function savetimestamp(hObj,eventdata) %#ok
  %SAVETIMESTAMP save real timestamp
  
    try
        %parse timestamp
        [hh,mm,ss] = strread( get(ui.index,'String'), '%f:%f:%f' );
        %save timestamp for current frame
        video_index(current_frame) = 3600*hh + 60*mm + ss;
    catch
        %something wrong, let's notify user
        beep
    end
    
  end
  
  function retval = wheelfcn(hObj, eventdata) %#ok
  %WHEELFCN mouse wheel callback
  
  retval = 1;
  
  if bitand( 1, eventdata.Modifiers ) %shift
      step = large_step;
  elseif bitand( 2, eventdata.Modifiers ) %control
      step = medium_step;
  else
      step = small_step;
  end
  
  if stepframe(sign(eventdata.WheelRotation).*step)
      update_img();
  end
  
  end

  function retval = keypressfcn(hObj, eventdata) %#ok
  %KEYPRESSFCN key press callback
  
  retval = 1;
  switch eventdata.KeyCode
   case 37 %left
    b=stepframe(-small_step);
   case 39 %right
    b=stepframe(small_step);
   case 33 %pgup
    b=stepframe(large_step);
   case 34 %pgdwn
    b=stepframe(-large_step);
   otherwise
    retval = 0;
    return
  end  
  
  if b
    update_img()
  end
  
  end

  function result = stepframe(step)
  %STEPFRAME get new frame after step
  
  result = true;
  try
      %update current frame
      current_img = getframe( hVid, hVid.CurrentFrame + step );
      current_frame = hVid.CurrentFrame;
  catch
      %somethinf wrong, let's notify user
      beep;
      result = false;
  end
  
  end

  function update_img()
  %UPDATEIMG update video image in axes
  
  image(current_img, 'Parent', ui.axis);
  set( ui.frame, 'String', num2str(current_frame) );
  
  end

end