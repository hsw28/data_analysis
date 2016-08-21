function d = calcMinDistance(a,b)
  d = sqrt(bsxfun(@plus,dot(a,a,1)',dot(b,b,1))-2*a'*b);
end