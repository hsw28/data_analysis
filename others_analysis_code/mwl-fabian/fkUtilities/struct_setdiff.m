function S = struct_setdiff( S1, S2, strict )
%STRUCT_SETDIFF returns fields in structure S1 that are not present in S2
%
%  s=STRUCT_SETDIFF(s1,s2) returns the fields in s1 that are not present
%  in s2. The function recurses if the same field is present in both
%  structs and the two fields themselves are structs.
% 
%  s=STRUCT_SETDIFF(s1,s2,1) if a field is a struct in s1, but not a
%  struct in s2 (or vice versa), then the fields are considered to be
%  different and thus the field IS returned in the result.
%
%  See also STRUCT_UNION, STRUCT_INTERSECT
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(strict)
  strict = 1;
end

if ~isstruct(S1) || ~isstruct(S2)
    error('struct_setdiff:invalidArguments', 'Invalid structures')
end

%do the comparison
S = struct_compare( S1, S2 );


  function S1 = struct_compare( S1, S2 )
  %STRUCT_COMPARE

  fn1 = fieldnames(S1);
  fn2 = fieldnames(S2);

  commonfields = intersect( fn1, fn2 );

  %for common fields either recurse, remove the field or retain the field
  for k=1:numel(commonfields)
    
    if isstruct( S1(1).(commonfields{k}) ) && isstruct( S2(1).(commonfields{k}) )
      
      for l=1:numel(S1)
        S1(l).(commonfields{k}) = struct_compare( S1(l).(commonfields{k}), S2(1).(commonfields{k}) );
      end
      
      if ~isstruct(S1(1).(commonfields{k})) || isempty( S1(1).(commonfields{k}) )
        
        S1 = rmfield(S1, commonfields{k} );
        
      end
      
    elseif ~strict ||  ( ~isstruct( S1(1).(commonfields{k}) ) && ~isstruct( S2(1).(commonfields{k}) ) )
      
      S1 = rmfield( S1, commonfields{k} );
      
    end
    
  end
  
  end

end
