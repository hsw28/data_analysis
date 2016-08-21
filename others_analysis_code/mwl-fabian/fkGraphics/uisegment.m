function S=uisegment(S, varargin)
%UISEGMENT gui to define segments
%
%  S=UISEGMENT() plots vector Y vs X in a slider plot, lets the user
%  define segments and returns the start and end times of each segment in
%  the nx2 matrix S. Middle mouse button adds a segment, right mouse
%  button deletes a segment.
%
%  S=UISEGMENT(X,Y,S) takes a nx2 matrix of initial segments
%

%if nargin<1
%  help(mfilename)
%  return
%end

[hAx, hS] = sliderplot( varargin{:} );
drawnow
enable_events(hAx);

set(hAx, 'DeleteFcn', @get_segments );

if nargin<1 || isempty(S)
  S = zeros(0,2);
end

if ~isnumeric(S) || ndims(S)~=2 || size(S,2)~=2
  error('uisegment:invalidSegments', 'Invalid segments')
end

cursors = handle( zeros(size(S,1),0) );

for k=1:size(S,1)

  cursors(k) = rangecursor(hAx, S(k,:), [0 1], 'Style', 'vertical', 'Color', [1 0.8 0.6]);
  
  enable_events( cursors(k) );
  add_callback( cursors(k), 'MyButtonUpFcn', @delete_segment );
  
  L = handle.listener(cursors(k), 'CursorChanged', @plot_segments_in_slider);
  setappdata(cursors(k),'listener',L);
  
end

ui.slidersegments = [];
plot_segments_in_slider();

add_callback( hAx, 'MyButtonUpFcn', @add_segment );

  function get_segments(hObj,eventdata) %#ok
  S=zeros(0,2);
  for k=1:numel(cursors)
    S(k,:) = cursors(k).XLim;
  end
  end

  function plot_segments_in_slider(hObj, eventdata) %#ok
  delete(ui.slidersegments);
  hsliderui=get(hS,'ui');
  S = zeros(0,2);
  for k=1:numel(cursors)
    S(k,:) = cursors(k).XLim;
  end
  ui.slidersegments = seg_plot( S, 'Axis', hsliderui.ax, 'FaceColor', [0.6 0.2 0.6]);
  end

  function retval = add_segment( hAx, e ) %#ok
  
  if e.Button~=2
    retval=false;
    return
  end
    
  retval = false;
  
  if bitand(e.Modifiers,3) %no shift or control
    return
  end
  
  w = 0.1*diff( xlim(hAx) );
  cp = e.HitPoint(1);
  
  cursors(end+1) = rangecursor(hAx, cp+[-0.5 0.5]*w, [0 1], 'Style', 'vertical', ...
                               'Color', [1 0.8 0.6]);  
  
  enable_events( cursors(end) );
  add_callback( cursors(end), 'MyButtonUpFcn', @delete_segment );
  
  L = handle.listener(cursors(end), 'CursorChanged', @plot_segments_in_slider);
  setappdata(cursors(end),'listener',L);  
  
  plot_segments_in_slider();
  
  retval = true;
  
  end
  
  function retval = delete_segment( h, e) %#ok

  if e.Button~=2
    retval=false;
    return
  end
  
  retval = true;
    
  idx = find( double(cursors) == double(h) );
  delete(cursors(idx));
  cursors(idx) = [];

  plot_segments_in_slider();
  
  end

uiwait(gcf);

end

