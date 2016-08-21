function val = subsref( G, s )
%SUBSREF subscripted referencing
%
%  val=SUBSREF(grid,subs) support for subscripted referencing to allow
%  access to grid structure properties.
%

%  Copyright 2006-2008 Fabian Kloosterman

val = G.grid;

for k=1:numel(s)

  val = subsref( val, s(k) );
  
end