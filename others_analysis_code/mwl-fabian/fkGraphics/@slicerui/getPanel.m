function p = getPanel(SUI)
%GETPANEL get slicer panel
%
%  hp=GETPANEL(slicer) returns the main panel of the slicer ui.
%

A = SUI.hash.get('slicer');
p = A.ui.mainpanel;