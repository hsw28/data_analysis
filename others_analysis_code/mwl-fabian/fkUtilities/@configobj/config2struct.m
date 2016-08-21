function s = config2struct( C )
%CONFIG2STRUCT convert configobj to struct
%
%  s=CONFIG2STRUCT(c) Convert the key/value pairs in a configobj to a
%  matlab struct. Comments are lost in this conversion.
%

%  Copyright 2005-2008 Fabian Kloosterman

s = C.keys;

fn = fieldnames( C.subsections );

if isempty(fn) && all( structfun(@(x) isa(x, 'cell') && isempty(x), s ) )

    tmp = cell( 1, numel(fieldnames(s))*2 );    
    tmp(1:2:end) = fieldnames( s );
    tmp(2:2:end) = struct2cell( s );

    s = struct( tmp{:} );
    
else

    for k=1:numel(fn)
  
        s.(fn{k}) = config2struct( C.subsections.(fn{k}) );
  
    end

end