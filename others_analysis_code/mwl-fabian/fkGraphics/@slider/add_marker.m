function add_marker(S, marker_name, marker)
%ADD_MARKER add marker to slider
%
%  ADD_MARKER(slider,name,marker) adds (or replaces) the marker under the
%  specified name to the slider object. A marker can be either a vector
%  or a nx2 matrix of segments.
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:add_marker:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

if nargin<3
  error('slider:add_marker:invalidInputs', 'Too few arguments')
end

if ~ischar(marker_name) || strcmp(marker_name, 'none')
  error('slider:add_marker:invalidInputs', 'Invalid marker name')
end

if isnumeric(marker) && ndims(marker)==2 && size(marker,2)==2 && size(marker,1)>0
  isseg = 1;
  [dummy, idx] = sort( marker(:,1) ); %#ok
  marker = marker(idx,:);
  if any(diff(marker,1,2)<=0)
    error('slider:add_marker:invalidInputs', 'Invalid marker')
  end
elseif isnumeric(marker) && isvector(marker)
  isseg = 0;
  marker = sort(marker(:));
else
  error('slider:add_marker:invalidInputs', 'Invalid marker data')
end

Sappdata = getappdata(S.parent, 'Slider');

fn = fieldnames( Sappdata.markers );

if ismember(marker_name, fn)
  %marker exists, replace
  Sappdata.markers.(marker_name)  = marker;
  if strcmp(Sappdata.currentmarker, marker_name)
    %delete current marker
    try
      delete(Sappdata.ui.hmarker);
    catch
    end
    
    Sappdata.currentmarkerval = NaN;
    
    if isseg
      Sappdata.ui.hmarker = seg_plot( Sappdata.markers.(Sappdata.currentmarker), ...
                                      'Axis', Sappdata.ui.ax, ...
                                      'EdgeColor', [1 0.75 0.5], 'FaceColor', ...
                                      [1 0.75 0.5], 'PlotArea', 0, 'Height', ...
                                      1, 'YOffset', 0.5);
    else
      Sappdata.ui.hmarker = event_plot( Sappdata.markers.( Sappdata.currentmarker ...
                                                        ), 'Axis', Sappdata.ui.ax );
    end
    set( Sappdata.ui.hmarker, 'HitTest', 'off');
    set( Sappdata.ui.ax, 'Children', [Sappdata.ui.text; Sappdata.ui.hmarker(:); Sappdata.ui.patch]);
    
  end

else
  
  Sappdata.markers.(marker_name) = marker;
  cb = get( Sappdata.ui.markermenu_items(1), 'Callback');
  Sappdata.ui.markermenu_items(end+1) = uimenu( Sappdata.ui.markermenu, ...
                                                'Label', marker_name, 'Callback', cb);
  
end

setappdata(S.parent, 'Slider', Sappdata);