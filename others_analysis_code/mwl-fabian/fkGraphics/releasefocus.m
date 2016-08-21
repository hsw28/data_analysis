function releasefocus( hObj )
%RELEASEFOCUS transfers focus from an object to its parent figure
%
%  RELEASEFOCUS(h) transfer focus from object h to its parent
%


if nargin<1
  return
end

hFig = ancestor( hObj, 'figure' );

if ~isempty(hFig)
  
  jh = get(handle(hFig), 'javaframe');
  requestFocus( jh.fTopLevelPanel );
  
end
