function p = getGrid(SUI)
%GETGRID get slicer grid  
%
%  g=GETGRID(slicer) returns the grid of the slicer ui.
%

A = SUI.hash.get('slicer');
p = A.grid;