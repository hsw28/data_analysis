function fireUpdateEvent(S)
%FIREUPDATEEVENT trigger event
%
%  FIREUPDATEVENT(slider) forces the execution of the callbacks
%  associated with the slider.
%

Sappdata = getappdata(S.parent, 'Slider');

if Sappdata.suspend_callback
  return
end

suspend_callback(S,1);

process_callbacks( Sappdata.updatefcn, S.parent, Sappdata.center, ...
                     Sappdata.windowsize );

suspend_callback(S,0);

end