function remove_marker(S, marker_name)
%REMOVE_MARKER removes marker from slider
%
%  REMOVE_MARKER(slider,name) removes marker with specified name from
%  slider.
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:remove_marker:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

if nargin<2
  error('slider:remove_marker:invalidInputs', 'Too few arguments')
end

if ~ischar(marker_name) || strcmp(marker_name, 'none')
  error('slider:add_marker:invalidInputs', 'Invalid marker name')
end

Sappdata = getappdata(S.parent, 'Slider');

fn = fieldnames( Sappdata.markers );

idx = find( strcmp( marker_name, fn ) );

if isempty(idx)
  return
end

Sappdata.markers = rmfield(Sappdata.markers, marker_name);

delete( Sappdata.ui.markermenu_items(idx+1) );
Sappdata.ui.markermenu_items(idx+1) = [];

if strcmp(Sappdata.currentmarker, marker_name)
  Sappdata.currentmarker = 'none';
  Sappdata.currentmarkerval = NaN;
  try
      delete(Sappdata.ui.hmarker);
  catch
  end
  Sappdata.ui.hmarker = [];
  set(Sappdata.ui.markermenu_items(1), 'Checked', 'on' );
end

setappdata(S.parent, 'Slider', Sappdata);