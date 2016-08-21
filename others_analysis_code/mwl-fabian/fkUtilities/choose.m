function c = choose( cl, n, group, option )
%CHOOSE return all possible combinations
%
%  c=CHOOSE(v) returns all combinations of 2 elements from the vector v.
%
%  c=CHOOSE(v,n) returns all combinations of n elements from vector
%  v. This is the same as the function nchoosek.
%
%  c=CHOOSE(v,n,groupid) each element in v is made a member of a group by
%  assigning it a group id. The group vector can be either numeric or a
%  cell array of strings. The function returns all combinations of n
%  elements within groups.
%
%  c=CHOOSE(v,n,groupid,'between') returns all combinations of n elements
%  between groups. All elements in a combination come from a different
%  group.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
end

if nargin<2
    n = 2;
end

if n==1
    c = cl;
    return
end


if nargin<3
  %find all combinations of n elements out of k observations
  c = nchoosek( cl, n );
    
else
  %convert group ids to numbers if it is a cell array
  if iscell( group )
    [group_sorted, si] = sort( group ); %#ok
    [dummy, dummy, tj] = unique( group(:) ); %#ok
    group = tj( si (si) );
  end

  
  if numel(group)~=numel(cl)
    error('choose:invalidGroup', 'Invalid group vector')
  end
  
  if nargin<4
    option = 'within';
  end
    
  switch option
   case 'within'
    %find all combinations within groups
    c = zeros(0,n);
    [t_unique, ti, tj] = unique( group(:) ); %#ok
    for k = 1:numel(t_unique)
      tmp = cl( tj==k );
      if numel(tmp)>=n
        c = [c;nchoosek( cl( tj==k ), n)];
      end
    end
      
   case 'between'
    %find all combination between groups
    if numel(cl)>=n 
      all_combi = nchoosek(1:numel(cl), n);
      all_combi_t = group( all_combi );
      c = all_combi( all( diff( sort(all_combi_t,2), [], 2 )>0 , 2), : );
      c = cl( c );
    end
      
      
   otherwise
    error('choose:invalidOption', 'Invalid option')
  end
    
end
