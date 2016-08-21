function S = struct_union( S1, S2 )
%STRUCT_UNION return the union of two structures
%
%  s=STRUCT_UNION(s1,s2) returns the union of two structures. If a field
%  is present in both s1 and s2 and at least one of the fields is not a
%  struct then the field from s2 is added. If both fields are structs the
%  function recurses. s1 and s2 should have the same dimensions. 
%
%  See also STRUCT_SETDIFF, STRUCT_INTERSECT
%

%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
if nargin<2
    help(mfilename)
    return
end

if ~isstruct(S1) || ~isstruct(S2)
    error('struct_union:invalidArguments', 'Invalid structures')
end

%do the comparison
S = struct_compare( S1, S2 );



function S = struct_compare( S1, S2 )
%STRUCT_COMPARE
%for each field name:
%  if present in only one: add to S
%  if present in both and at least one is not a struct: add field from S2
%  if present in both and both are structs: recurse (except when their size
%  are not equal, then proceed as point 2 above )

n1 = numel(S1);
n2 = numel(S2);

if n1~=n2 || ndims(S1)~=ndims(S2) || ~all(size(S1)==size(S2))
    error('struct_union:noMerge', 'Struct arrays have different size: cannot merge')
end

fn1 = fieldnames(S1);
fn2 = fieldnames(S2);

if n1==0
  fn = union( fn1, fn2);
  S = cell2struct( repmat( {[]}, numel(fn), 1), fn );
  S(1) = [];
  return
end

commonfields = intersect( fn1, fn2 );
S1_only = setdiff( fn1, fn2 );
S2_only = setdiff( fn2, fn1 );

S = repmat( struct(), size(S1) );

%add S1 only and S2 only fields
for k=1:numel(S1_only)
    [S(:).(S1_only{k})] = deal( S1(:).(S1_only{k}) );
end
for k=1:numel(S2_only)
    [S(:).(S2_only{k})] = deal( S2(:).(S2_only{k}) );
end

%for common fields act appropriately
for k=1:numel(commonfields)

    if isstruct( S1(1).(commonfields{k}) ) && isstruct( S2(1).(commonfields{k}) ) && ndims(S1(1).(commonfields{k}))==ndims(S2(1).(commonfields{k})) && all(size(S1(1).(commonfields{k}))==size(S2(1).(commonfields{k})))

        [S(:).(commonfields{k})] = deal( struct_compare( S1(:).(commonfields{k}), S2(:).(commonfields{k}) ) );
               
    else
        
        [S(:).(commonfields{k})] = deal( S2(:).(commonfields{k}) );
        
    end
    
end
