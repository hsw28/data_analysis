function display(L)
%DISPLAY show layoutmanager info
%
%  DISPLAY(L)
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  disp('layout manager - invalid handle')
else
  Lappdata = getappdata(L.parent, 'LayoutManager');
  disp(['layout manager - parent = ' num2str(L.parent)])
  disp(Lappdata)
end