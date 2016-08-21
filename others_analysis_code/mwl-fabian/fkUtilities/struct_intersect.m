function S = struct_intersect( S1, S2, strict )
%STRUCT_INTERSECT returns fields in S1 that are present in S2
%
%  s=STRUCT_INTERSECT(s1,s2) returns a structure that is the intersection
%  between the structures s1 and s2. Only fields that are present in both
%  structs are returned. The function will recurse if both fields are
%  structs.
%
%  s=STRUCT_INTERSECT(s1,s2,1) structs and non-structs are treated as
%  being different and thus when a field is a struct in s1 but not in
%  s2 (or vice versa), than that field will not be in the output
%  structure
%
%  See also STRUCT_SETDIFF, STRUCT_UNION
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(struct)
  strict = 0;
end

if ~isstruct(S1) || ~isstruct(S2)
    error('struct_intersect:invalidArguments', 'Invalid structures')
end

%do the comparison
S = struct_compare( S1, S2 );


  function S = struct_compare( S1, S2 )
  %STRUCT_COMPARE
  %for each field name:
  %  if present in only in one: skip field
  %  if present in both and S2.field is not a struct: add field from S1
  %  if present in both and S2.field is a struct, but S1.field is not: skip
  %  if present in both and both are structs: recurse

  fn1 = fieldnames(S1);
  fn2 = fieldnames(S2);

  commonfields = intersect( fn1, fn2 );

  S = repmat( struct(), size(S1) );

  %for common fields act appropriately
  for k=1:numel(commonfields)
    
    if ~strict && isstruct( S1(1).(commonfields{k}) )~=isstruct( S2(1).(commonfields{k}) )
        
      [S(:).(commonfields{k})] = deal( S1(:).(commonfields{k}) );
        
    elseif isstruct( S1(1).(commonfields{k}) ) && isstruct( S2(1).(commonfields{k}) )
        
      [S(:).(commonfields{k})] = deal( struct_compare( S1(:).(commonfields{k}), S2(:).(commonfields{k}) ) );
               
    elseif ~isstruct( S1(1).(commonfields{k}) ) && ~isstruct( S2(1).(commonfields{k}) )
        
      [S(:).(commonfields{k})] = deal( S1(:).(commonfields{k}) );
        
    end
    
  end

  if isempty( fieldnames(S) )
    S = struct();
  end
  
  end

end
