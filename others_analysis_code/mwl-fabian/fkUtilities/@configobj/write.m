function success = write(C, filename)
%WRITE write configobj to file
%
%  success=WRITE(c,filename) writes the contents of a configobj to a file
%  with the specified file name. If no file name is given, then the
%  contents will be displayed on the screen (i.e. just a dump)
%

%  Copyright 2005-2008 Fabian Kloosterman

%fall back to dump, if no filename is specified
if nargin<2
  dump(C)
  return
end

%try writing to file
try
  fid = fopen( filename, 'w' );
  fwrite( fid, dump(C) );
  fclose(fid);
  success = 1;
catch
  success = 0;
end
