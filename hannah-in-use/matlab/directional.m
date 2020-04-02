function f = directional(matrix)
%input matrix should be cluster size, direction, x, y (can have other sutff after if wanted)
% output of 1 is unidirectional, 2 is bidirectional


direct = NaN(size(matrix,1),1);

for l=1:size(matrix,1)


  if isnan(matrix(l,3))==1
    direct(l) = NaN;
    continue
  end

  sizematch = find(matrix(l,1) == matrix(:,1)); %matching size
    if length(sizematch)<=1
      direct(l) = 1;
      continue
    end

  oppdir = find(matrix(l,2) ~= matrix(:,2)); %opposite direction
  sizeanddirect = intersect(sizematch, oppdir);
    if length(sizeanddirect)==0
      direct(l) = 1;
      continue
    end

  currdis = 1000;
  for z=1:length(sizeanddirect)
    X = [matrix(l,3),matrix(l,4);matrix(sizeanddirect(z),3),matrix(sizeanddirect(z),4)];
    d = pdist(X,'euclidean');
    if d<currdis
      currdis = d;
    end
  end

    if currdis<70 %equal to 20cm
      direct(l) = 2;
    else
      direct(l) = 1;
    end





end

f = direct;
