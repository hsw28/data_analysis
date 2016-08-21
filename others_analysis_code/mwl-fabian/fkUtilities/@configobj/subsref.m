function val = subsref( C, s )
%SUBSREF get key or subsection from configobj
%
%  val=SUBSREF(c,subs) support for subscripted reference. Recursive
%  referencing is allowed. Valid syntaxes are:
%  1. val=cobj.key - retrieve value of key
%  2. section=cobj.subsection - retrieve subsection (which is another
%                               configobj)
%

%  Copyright 2005-2008 Fabian Kloosterman

%only process '.' indexing
s = s( strcmp( {s.type}, '.' ) );
n = numel(s);

if n==0
  val = [];
  return
end

%existing key or section?
iskey = ismember( s(1).subs, fieldnames( C.keys ) );
issection = ismember( s(1).subs, fieldnames( C.subsections ) );

if issection && n==1
  val = C.subsections.(s(1).subs); %return section
elseif iskey && n==1 %return key value
  val = C.keys.(s(1).subs);
elseif iskey %no recursion for keys
  error('ConfigObj:subsref:invalidIndex', ['Keys do not have ' ...
                      'subsections']);
elseif issection && n>1 %recurse
  val = subsref( C.subsections.(s(1).subs), s(2:end) );
else
  error('ConfigObj:subsref:invalidKey', ['Invalid key: ' s(1).subs]);
end
