function L = subsasgn(L, s, val)
%SUBSASGN create/update/delete sections or keys in diagnostics object
%
%  l=SUBSASGN(l,subs,val) support for subscripted assignment of keys and
%  deletion of keys and logs. Keys cannot start with 'log'; the key
%  'created' is a read-only key and cannot be modified. New logs cannot
%  be added using subscripted assignment, use addlog for this. Valid
%  syntaxes are:
%   1. log.key=val - create/update key value
%   2. log.key=[]  - delete key
%   3. log.log=[]  - delete log
%

%  Copyright 2005-2008 Fabian Kloosterman


%only process '.' indexing
s = s(strcmp( {s.type}, '.' ) );
n = numel(s);

if n==0
  return
elseif n>1
  error('Diagnostics:subsasgn:invalidKey', ['Not allowed to add/change sections' ...
        'this way'])
end

if ismember( s(1).subs, sections( L.configobj ) ) && ~isempty(val);
  error('Diagnostics:subsasgn:invalidKey', ['Not allowed to change a log ' ...
                      'section'])
elseif strcmp( s(1).subs, 'created' )
  error('Diagnostics:subsasgn:invalidKey', ['Not allowed to modify read only ' ...
                      'key ''created'''])
elseif strncmp( s(1).subs, 'log', 3 ) && ~isempty(val)
  if isa(val, 'configobj')
    error('Diagnostics:subsasgn:invalidKey', ['Use addlog method to add a new ' ...
                        'diagnostics log'])
  else
    error('Diagnostics:subsasgn:invalidKey', ['Keys are not allowed to start ' ...
                        'with ''log'''])
  end
end

L.configobj = subsasgn( L.configobj, s, val );
