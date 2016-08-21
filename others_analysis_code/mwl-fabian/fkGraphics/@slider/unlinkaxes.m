function unlinkaxes(S, hAx)
%UNLINKAXES unlink axes and slider
%
%  UNLINKAXES(slider) unlink all axes
%
%  UNLINKAXES(slider) unlink specified axes
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:unlinkaxes:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

%for multiple axes recurse
if numel(hAx)>1
  for k=1:numel(hAx)
    unlinkaxes( S, hAx(k) )
  end
  return
end

Sappdata = getappdata( S.parent, 'Slider');

if nargin<2
  
  %unlink all axes
  Sappdata.linkedaxes(:) = [];
  
else
    
  if ~all(ishandle(hAx)) || ~all(strcmp(get(hAx, 'Type'), 'axes'))
    error('slider:unlinkaxes:invalidHandle', 'Invalid axes')
  end
  
  %[idx, idx] = intersect([Sappdata.linkedaxes.axes], hAx ); %#ok
  Sappdata.linkedaxes( ismember([Sappdata.linkedaxes.axes],hAx ) ) = [];
  
end

setappdata(S.parent, 'Slider', Sappdata);