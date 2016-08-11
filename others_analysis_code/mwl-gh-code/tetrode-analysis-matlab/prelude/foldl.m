function retA = foldl( funABA, initA, cellB )
% Fold funABA over initial value initA and cellarray cellB

if(~iscell(cellB))
    cellB = mat2cell( cellB(:), 1 );
end

retA = initA;

for n = 1:numel(cellB)
    retA = funABA( retA, cellB{n} );
end