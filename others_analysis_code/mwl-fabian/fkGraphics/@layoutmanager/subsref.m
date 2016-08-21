function val = subsref(L,s)
%SUBSREF subscripted reference of layout manager objects
%
%  val=SUBSREF(l,subs) support for subscripted referencing. Properties of
%  the layour manager object can be retrieved using the dot
%  notation. '()' indexing can be used to directly access the matrix of
%  child handles.
%

switch s(1).type
 case '.'
  val = get(L, s(1).subs);
  if numel(s)>1
      val = subsref( val, s(2:end) );
  end
 case '()'
  hAx = get(L,'childmatrix');
  val = hAx(s(1).subs{:});
end