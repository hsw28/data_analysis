function [X, I, J] = randswap(X, dimmode)
%RANDSWAP randomly swap elements of a matrix
%
%   y=RANDSWAP(x) randomly swaps the elements of vector X. For N-D
%   matrices, RANDSWAP(X) randomly swaps the elements along the first 
%   non-singleton dimension of X. 
%
%   y=RANDSWAP(x,dim) randomly swaps the elements along the dimension
%   dim. For instance, RANDSWAP(X,1) randomly interchanges the rows of x.
%
%   y=RANDSWAP(x,'partial') swaps the elements for each of the
%   non-singleton dimensions of x separately. Rows are interchanged first,
%   then columns, then planes, etc. In this case, elements that belong to
%   the same row, column, ... stay together.
%
%   y=RANDSWAP(x,'full') randomly swaps all the elements in X.
%
%   [y,i,j]=RANDSWAP(...) return index matrices i and j so that 
%   y=x(i) and x=y(j). 
%
%   x can be a numeric or a cell array.
%
%  Example
%    % randomize a vector
%    RANDSWAP(1:5) % -> e.g. [3 5 1 2 4]
%
%    % Randomize along first non-singleton dimension (rows)
%    X = reshape(1:16,4,4) ; % test matrix
%    RANDSWAP(X) % ->  1     5     9    13
%                %     3     7    11    15
%                %     4     8    12    16
%                %     2     6    10    14
%
%    % Randomize along all dimensions (swap rows, then columns)
%    X = reshape(1:9,3,3) ; % test matrix
%    RANDSWAP(X,'partial') % ->  2    8   5
%                          %     1    7   4
%                          %     3    9   6
%
%    % Swap all elements
%    X = reshape(1:9,3,3) ; % test matrix
%    RANDSWAP(X,'full') % ->  9    5     6
%                       %     4    1     8    
%                       %     7    3     2
%
%   See also RAND, RANDPERM, SHAKE
%

% for Matlab R13
% version 1.0 (oct 2006)
% (c) Jos van der Geest
% email: jos@jasen.nl

% This function is a generalization of SHAKE.

error(nargchk(1,2,nargin)) ;

if nargin==1,
    % default: shake along first non-singleton dimension
    dimmode = 0;
    dim = 0;
else
    if ischar(dimmode),
        dimmode = strncmpi(dimmode,{'full','partial'},length(dimmode)) ;
        if isempty(dimmode),
            error('randswap:invalidArgument', 'String argument should be ''full'' or ''partial''.') ;
        end
    else
        if ~isnumeric(dimmode) || numel(dimmode)~= 1 || fix(dimmode) ~= dimmode || dimmode < 0,
          error('randswap:invalidDimension', 'Dimension argument should be a positive integer.') ;
        end
        dim = dimmode;
        dimmode = 0;
    end
end

% information on X
szX = size(X) ;
ndX = ndims(X) ;
neX = numel(X) ;

% index matrix
I = reshape(1:neX, szX) ; 

if neX > 0,
    switch dimmode,
        case 1, % 'full' - swap all indices
            I(randperm(neX)) = I ;
        case 2,% 'partial' - swap indices of every dimension
            ind = repmat({':'},ndX,1) ;
            SI = find(szX>1) ;
            % loop over all dimensions with a size > 1
            for i = SI,
                ind{i} = randperm(szX(i)) ;
                I = subsref(I,substruct('()',ind)) ;
                ind{i} = ':' ;
            end
        otherwise
            % swap indices of a specific dimension
            if dim==0,
                % first non-singleton dimension
                dim = find(szX>1,1,'first') ;
            end
            if dim <= ndX && szX(dim) > 1,
                % interchange indices in one dimention only
                ind = repmat({':'},ndX,1);
                ind{dim} = randperm(szX(dim)) ;
                I = subsref(I,substruct('()',ind)) ;
            end
    end    
    % randomize using indices
    X = X(I) ;
end

if nargout==3,
    J = zeros(szX) ;
    J(I) = 1:neX ;
end

