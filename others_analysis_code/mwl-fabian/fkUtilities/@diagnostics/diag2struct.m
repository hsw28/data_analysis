function s = diag2struct( L )
%DIAG2STRUCT convert diagnostics object to struct
%
%  s=DIAG2STRUCT(d) convert the logs in the diagnostics object to a
%  matlab struct. Comments are lost.
%

%  Copyright 2005-2008 Fabian Kloosterman

s = config2struct( L.configobj );
