function val = subsref(S,s)
%SUBSREF subscripted reference
%
%  val=SUBSREF(slider,subs) allows retrieving slider object properties
%  using dot notation.
%

switch s.type
 case '.'
  val = get(S, s.subs);
end