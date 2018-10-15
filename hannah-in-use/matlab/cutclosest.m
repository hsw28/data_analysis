function f = cutclosest(cutstart, cutend, timevector4comp, vector2cut)

[c startindex] = min(abs(timevector4comp-cutstart));
[c endindex] = (min(abs(timevector4comp-cutend)));

if size(vector2cut, 2) > size(vector2cut, 1)
  vector2cut = vector2cut';
  i = 1;
else
  i = 0;
end

newvector = vector2cut(startindex:endindex, :);

if i ==1
f = newvector';
else
f = newvector;
end
