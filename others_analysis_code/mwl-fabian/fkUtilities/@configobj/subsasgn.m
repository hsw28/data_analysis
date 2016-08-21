function C = subsasgn(C, s, val)
%SUBSASGN create/update/delete sections or keys in configobj
%
%  c=SUBSASGN(c,subs,val) adds support for subscripted
%  assignment. Assignment can be done recursively. Valid
%  syntaxes are:
%   1. cobj.key=val - create/update key value
%   2. cobj.key=[]  - delete key
%   3. cobj.section=configobj(...) - create/update subsection
%   4. cobj.section=[] - delete section
%
%  Example
%
%    c=configobj();
%    c.a=configobj();
%    c.a.b = 1;
%

%  Copyright 2005-2008 Fabian Kloosterman


%only process '.' indexing
s = s( strcmp( {s.type}, '.' ) );
n = numel(s);

if n==0
  return
end

%check for valid value
if ~isa(val, 'configobj') && ...
      (~isnumeric(val) || ndims(val)>2) && ...
      ~ischar(val) && ...
      (~iscell(val) || ndims(val)>2) && ...
      ~islogical(val)
  error('ConfigObj:subsasgn:invalidValue', 'Invalid value')
end

%existing key or section?
iskey = ismember( s(1).subs, fieldnames( C.keys ) );
issection = ismember( s(1).subs, fieldnames( C.subsections ) );


if issection && n==1
  if isa(val, 'configobj') %update subsection
    C.subsections.(s(1).subs) = val;
  elseif ~isempty(val) %invalid value
    error('ConfigObj:subsasgn:invalidIndex', ['Sections do not hold ' ...
                        'values']);
  else %delete subsection
    C.subsections = rmfield(C.subsections, s(1).subs);
  end
elseif iskey && n==1
  if ~isempty(val) %update key
    C.keys.(s(1).subs) = val;
  else %delete key
    C.keys = rmfield(C.keys, s(1).subs);
    C.comments = rmfield(C.comments, s(1).subs);
    C.inline_comments = rmfield(C.inline_comments, s(1).subs);
  end
elseif iskey %no recursion for keys
  error('ConfigObj:subsasgn:invalidIndex', ['Keys do not have ' ...
                      'subsections']);
elseif issection %recurse
  C.subsections.(s(1).subs) = subsasgn( C.subsections.(s(1).subs), s(2:end), ...
                                        val);
else %create key or section
  if n>1 %create subsection and recurse
    C.subsections.(s(1).subs) = configobj();
    C.subsections.(s(1).subs) = subsasgn( C.subsections.(s(1).subs), s(2:end), ...
                                          val);    
  elseif isa(val, 'configobj') %create subsection
    C.subsections.(s(1).subs) = val;
  else %create key
    C.keys.(s(1).subs) = val;
    C.comments.(s(1).subs) = {};
    C.inline_comments.(s(1).subs) = '';
  end
end
