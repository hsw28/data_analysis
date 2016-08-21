function display(L)
%DISPLAY display diagnostics object
%
%  DISPLAY(d) print contents of a diagnostics object on the command
%  line.
%

%  Copyright 2005-2008 Fabian Kloosterman

disp( ['Diagnostics File: ' L.filename])
display( L.configobj )
