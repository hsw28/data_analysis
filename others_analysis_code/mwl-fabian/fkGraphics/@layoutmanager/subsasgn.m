function L = subsasgn(L,s,v)
%SUBSASGN subscripted assignment
%
%  l=SUBSASGN(l,subs,val) support subscripted assignment for layout
%  manager objects.
%


switch s(1).type
 case '.'
     if numel(s)>1
         val = get(L, s(1).subs);
         val = subsasgn( val, s(2:end), v );
         L = set(L, s(1).subs, val );
     else
         L = set(L, s(1).subs, v);
     end
end