function val = tostr( val )
%TOSTR convert to string
%
%  s=TOSTR(val) convert val to string.
%
%  See also MAT2STR, STRUCT2STR, CELL2STR, FUNC2STR
%

%  Copyright 2007-2008 Fabian Kloosterman

if isnumeric(val) || islogical(val)
  if isempty(val)
    val = '[]';
  else
    val = mat2str(val);
  end
elseif isstruct(val)
  val = struct2str(val);
elseif iscell(val)
  val = cell2str(val);
elseif isa(val, 'function_handle')
  val = func2str(val );
elseif ischar(val)
  %val = val;
else
  try
    val = char(val);
  catch
    val = NaN;
  end
end
