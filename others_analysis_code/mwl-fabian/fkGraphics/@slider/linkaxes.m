function linkaxes(S, hAx)
%LINKAXES links axes to slider
%
%  LINKAXES(slider,hax) links the x-axis of the axes objects to the
%  slider.
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:linkaxes:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

if nargin<2
  return
end

%for multiple axes recurse
if numel(hAx)>1
  for k=1:numel(hAx)
    linkaxes( S, hAx(k) )
  end
  return
end

if ~ishandle(hAx) || ~strcmp(get(hAx, 'Type'), 'axes')
  error('slider:linkaxes:invalidHandle', 'Invalid axes')
end

Sappdata = getappdata( S.parent, 'Slider');

if ismember( hAx, [Sappdata.linkedaxes.axes] )
  return
end

set( hAx, 'XLim', Sappdata.center + [-0.5 0.5]*Sappdata.windowsize );

hgpkg = findpackage('hg'); 
axclass = hgpkg.findclass('axes');
L(1) = handle.listener(hAx, axclass.findprop('XLim'), ...
                       'PropertyPostSet', {@link_fcn, S});
L(2) = handle.listener(hAx, 'ObjectBeingDestroyed', {@unlink_fcn, S});


Sappdata.linkedaxes(end+1) = struct('axes', hAx, 'listeners', L);

setappdata( S.parent, 'Slider', Sappdata );



function link_fcn(h, eventdata, S) %#ok

xl = get(eventdata,'NewValue');
set(S, 'center', mean(xl), 'windowsize', diff(xl));

function unlink_fcn(h, eventdata, S) %#ok

Sappdata = getappdata(S.parent, 'Slider');
idx = find( [Sappdata.linkedaxes.axes]==h );
Sappdata.linkedaxes(idx) = [];
setappdata(S.parent, 'Slider', Sappdata);
