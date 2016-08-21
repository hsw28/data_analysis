function set(S,varargin)
%SET set slider object properties
%
%  SET(slider,prop1,val1,...) sets slider object properties. Valid
%  properties are:
%   limits - slider limits
%   center - center of thumb
%   windowsize - size of thumb
%   updatemode - 'delayed'/'live'
%   displaymode - 'struct'/'+50%'/'window size'
%   color - color of thumb
%   currentmarker - name of current marker
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:set:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

valid_parms = {'limits', 'center', 'windowsize', ...
               'updatemode', 'color', 'currentmarker', 'displaymode'};

Sappdata = getappdata(S.parent, 'Slider');

[newdata, changed_parms] = validate_parms(Sappdata, valid_parms, varargin{:});

if any(ismember(changed_parms, {'limits', 'center', 'windowsize'}))
  set( newdata.ui.ax, 'XLim', newdata.limits );
  set( newdata.ui.limedit(1), 'String', num2str(newdata.limits(1)) );
  set( newdata.ui.limedit(2), 'String', num2str(newdata.limits(2)) );

  set( newdata.ui.center_edit, 'String', num2str(newdata.center) );

  set( newdata.ui.edit, 'String', num2str(newdata.windowsize) );
  
  set( newdata.ui.patch, 'XData', newdata.center + max( newdata.windowsize, ...
                                                    0.01.*diff(newdata.limits) ...
                                                    ).*[-0.5 0.5 0.5 -0.5], ...
                    'FaceColor', newdata.color, 'EdgeColor', ...
                    newdata.color);
end

update_linkedaxes( newdata );
  
  

if ~strcmp(newdata.currentmarker, Sappdata.currentmarker)
  set( newdata.ui.markermenu_items, 'Checked', 'off');
  idx = find( strcmp( newdata.currentmarker, vertcat({'none'}, fieldnames(newdata.markers))));
  set( newdata.ui.markermenu_items(idx), 'Checked', 'on');
  
  %delete current marker
  try
    delete(newdata.ui.hmarker);
  catch
  end
  
  switch newdata.currentmarker
   case 'none'
    newdata.ui.hmarker=[];
   otherwise
    newdata.ui.hmarker = event_plot( newdata.markers.( newdata.currentmarker ), 'Axis', newdata.ui.ax );        
  end
  
end

setappdata(S.parent, 'Slider', newdata);

if newdata.center~=Sappdata.center || newdata.windowsize~=Sappdata.windowsize
  fireUpdateEvent( S );
end

%call_callback( slider.UpdateFcn, slider.ui.ax, slider.Center, slider.WindowSize );