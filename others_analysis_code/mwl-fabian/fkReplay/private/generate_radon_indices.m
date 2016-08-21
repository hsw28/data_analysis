function cindex = generate_radon_indices(npos, UL, radonoptions)
%GENERATE_RADON_INDICES

cindex = struct('matrix', {}, 'invalid', {} );
  
for j=1:numel(UL)
    
  %compute radon transform
  [radon,nn] = radon_transform( zeros(npos,UL(j))', radonoptions{:} ); 
    
    
  %construct index matrix
  cindex(j).matrix = bsxfun(@plus, zeros( size(radon) ), shiftdim( 1:UL(j), -1 ) );

  cindex(j).invalid = ( repmat(nn(:,:,1)==0,[1 1 UL(j)]) | ...
                                ( repmat(nn(:,:,1),[1 1 UL(j)]) <= cindex(j).matrix  & ...
                                  repmat(nn(:,:,2), [1 1 UL(j)]) >= cindex(j).matrix ) ) ;
  cindex(j).matrix = (cindex(j).matrix-1).*npos;
end
