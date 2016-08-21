function v = binsearch( data, value, bias )
%BINSEARCH binary vector search
%
%  idx=BINSEARCH(data,value) find the index of the element in the
%  data vector that is nearest to the requested value using a fast
%  binar search algorithm. Data should be sorted; this is not
%  checked however (for performance reasons)
%
%  idx=BINSEARCH(data,value,bias) specify a bias, which can be any
%  of the following:
%   nearest - return index of data element closest to value (default)
%   post - return index of element equal to or larger than
%          requested value or NaN if value>last element in data
%   pre - return index of element equal to or smaller than
%         requested value or NaN if value<first element in data
%   strict - return index of element equal to value or NaN
%            otherwise.
%

%  Copyright 2008-2008 Fabian Kloosterman

%check input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3
    bias = 'nearest';
elseif ~any(strcmp(bias, {'nearest','post','pre','strict','<','<=','==','~','>','>='}))
    error('binsearch:invalidArgument', 'Invalid bias');
end

N = numel(data);

v = NaN( size( value ) );

%check value against first and last data elements
idx = data(1)>value;
if any( strcmp( bias, {'post','nearest','>','>=','~'} ) )
    v(idx) = 1;
end
idx = data(end)<value;
if any( strcmp( bias, {'pre', 'nearest','<','<=','~'} ) )
    v(idx) = N;
end

idx = find( isnan( v ) );

switch bias
    case {'post','>','>='}
        for k=1:numel(idx)
            v(idx(k)) = localbinsearch( data, value(idx(k)), N, 1 );
        end
    otherwise
        for k=1:numel(idx)
            v(idx(k)) = localbinsearch( data, value(idx(k)), N, 0 );
        end
end

%process bias
switch bias
    case {'pre', '<='}
        idx = data(v)>value;
        v(idx) = v(idx)-1;
    case {'<'}
        idx = data(v)>=value;
        v(idx) = v(idx) - 1;
    case {'post','>='}
        idx = data(v)<value;
        v(idx) = v(idx)+1;
    case {'>'}
        idx = data(v)<=value;
        v(idx) = v(idx) +1 ;
    case {'strict','=='}
        v( data(v)~=value ) = NaN;
    case {'nearest', '~'}
        idx = [ min(N, v(:)+1) v(:) max(1, v(:)-1) ];
        [mi,mi] = min( abs( bsxfun( @minus, data(idx), value(:) ) ), [], 2 );
        v = reshape( idx( (1:size(idx,1))' + (mi-1).*size(idx,1) ), size(v) );
end

v(v<1 | v>N)=NaN;

function v = localbinsearch( data, value, N, method )
    
low = 0;
high = N;

if method==1

    while (low < high)
        mid = floor((low + high)/2);
        if (data(mid+1) > value)
            high = mid;
        else
            low = mid + 1;
        end
    end
    
    v = low;
    
else
    
    while (low < high)
        mid = floor((low + high)/2);
        if (data(mid+1) < value)
            low = mid + 1;
        else
            high = mid;
        end
    end

    v = low+1;
    
end