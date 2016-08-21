function val = get( L, varargin )
%GET retrieve key or section from diagnostics object
%
%  key=GET(d,key) get the value of a key. If the key does not exist an
%  error is thrown.
%
%  key=GET(d,key,default) get the value of a key, or if the key does not
%  exist the default is returned.
%
%  section=GET(d,section) get a subsection. If the section does not exist
%  then an error is thrown.
%
%  section=GET(d,section,default) get a subsection, or if the subsection
%  does not exist the default is returned.
%

%  Copyright 2005-2008 Fabian Kloosterman


val = get( L.configobj, varargin{:} );
