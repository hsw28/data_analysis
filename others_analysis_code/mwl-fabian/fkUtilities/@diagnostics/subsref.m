function val = subsref(L, s)
%SUBSREF get key or log from diagnostics object
%
%  val=SUBSREF(l,subs) support for subscripted referencing. Recursive
%  indexing is possible. Valid syntaxes are:
%  1. val=log.key - get value of key
%  2. log=log.log - get log
%


%  Copyright 2005-2008 Fabian Kloosterman


val = subsref(L.configobj, s);
