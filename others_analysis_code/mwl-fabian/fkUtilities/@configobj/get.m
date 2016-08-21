function val = get( C, subs, default )
%GET retrieve key or section from configobj
%
%  key=GET(c,key) Get the value of a key. If key does not exist an error
%  is thrown.
%
%  key=GET(c,key,default) Get value of key or if key does not exist
%  return default.
%
%  c=GET(c,section) Get a subsection and return another configobj. If the
%  section does not exist an error is thrown.
%
%  c=GET(c,section,default) Get a subsection and return another
%  configobj. If subsection does not exist return default.
%
%

%  Copyright 2005-2008 Fabian Kloosterman


val = [];

if nargin<2
  return
end

if ~ischar(subs)
  error('ConfigObj:get:invalidArgument', 'Invalid key or section name')
end

if nargin>=3
  try
    val = subsref( C, struct('type', '.', 'subs', subs) );
  catch
    val = default;
  end
else
  val = subsref( C, struct('type', '.', 'subs', subs) );
end
  
