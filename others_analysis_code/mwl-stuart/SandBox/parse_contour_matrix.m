function [cont] = parse_contour_matrix(c)

if nargin==0
    error('Must provide a contour matrix');
elseif ~ismatrix(c)
    error('Must provide a contour matrix');
end

nCont = 0;
while ~isempty( c )
    nCont = nCont+1;
    [cont(nCont), c] = get_next_contour(c);  
end

nPts = arrayfun( @(x) size(x.x, 2), cont);
[~, idx] = sort(nPts, 2, 'descend');

cont = cont(idx);
end


function [cont, rem] = get_next_contour(c)



cont.level = c(1,1);
nPt = c(2,1);
if ~isInt(nPt)
    error('Invalid contour matrix');
end

cont.x = c(1,2: (nPt+1) );
cont.y = c(2,2: (nPt+1) );

if size(c,2)> (nPt+2)
    rem = c(:, (nPt+2) : end );
else
    rem = [];
end


end

function b = isInt(val)
    b = ( val == round(val) );
end