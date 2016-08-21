function v = values( C )
%VALUES get all key values from configobj
%
%  val=VALUES(c) returns a cell array with all values associated with the
%  keys in a configobj.
%

%  Copyright 2005-2008 Fabian Kloosterman

v = struct2cell( C.keys );
