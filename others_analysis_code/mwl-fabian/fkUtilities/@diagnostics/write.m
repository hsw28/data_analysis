function success = write( L )
%WRITE write diagnostics object to file
%
%  success=WRITE(d) writes the contents of a diagnostics to disk.
%

%  Copyright 2005-2008 Fabian Kloosterman

success = write( L.configobj, L.filename );