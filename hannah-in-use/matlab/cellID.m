function f = cellID(matrix)
%input matrix should be size first


direct = NaN(size(matrix,1),1);
curnum = 1;

for l=1:size(matrix,1)

  sizematch = find(matrix(l,12) == matrix(:,12)); %matching size
    if length(sizematch)<=1
      direct(l) = curnum;
      curnum=curnum+1;
    else
      curnum=curnum+1;
      direct(sizematch) = curnum;
    end
end

f = direct;
