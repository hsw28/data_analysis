function S = subsasgn(S,s,v)
%SUBSASGN subscripted assignment
%
%  s=SUBSASGN(s,subs,val) allows setting slider object properties using
%  the dot notation.
%

switch s.type
 case '.'
  S = set(S, s.subs, v);
end