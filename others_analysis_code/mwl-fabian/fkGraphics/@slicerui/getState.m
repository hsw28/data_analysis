function p = getState(SUI)
%GETSTATE returns the slicer state
%
%  s=GETSTATE(slicer) returns the state of the slicer.
%

A = SUI.hash.get('slicer');
p = A.state;