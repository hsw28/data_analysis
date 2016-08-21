function val=fieldnames(L)
%FIELDNAMES returns a cell array of valid properties
%
%  f=FIELDNAMES(layoutmanager)
%

Lappdata = getappdata(L.parent, 'LayoutManager');

val = vertcat({'parent'}, fieldnames( Lappdata ) );