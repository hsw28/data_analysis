function [coords,idx]=filtercoords(coords,filters)
%FILTERCOORDS filter a set of coordinates
%
%  coords=FILTERCOORDS(coords,filters) returns only those coordinates
%  that are retained by the set of filters. The filters argument is a
%  cell array with function handles for each dimension (column) of the
%  coordinates array.
%
%  [coords,idx]=FILTERCOORDS(...) also returns the logical index array
%  used for filtering.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

[n,m] = size(coords);

if ~iscell(filters) || ...
      numel(filters)~=m || ...
      ~all( cellfun('isclass', filters, 'function_handle') | ...
            cellfun('isempty', filters) )
  error('filtercoords:invalidArgument', 'Invalid filters')
end

idx = true(n,1);

for k=1:m
  
  if ~isempty(filters{k})
    [tmp,tmp] = filters{k}( coords(:,k) ); %#ok
    idx = idx & tmp;
  end
  
end

coords = coords(idx,:);
