function f = decodeshitACCSHIFT(timevector, clusters, vel, tdecode, t, maxSHIFT, shift_increment)
%allows you to shift decoding to see most accurate

clustname = (fieldnames(clusters));
numclust = length(clustname)

errors = zeros(maxSHIFT*2./shift_increment, 3);
k = -maxSHIFT;
z = 1;
while k<=maxSHIFT
  l = 1;
  while l <= numclust %subtract
      name = char(clustname(l));
      firingdata = clusters.(name);
      clustnum = strcat('c', num2str(l));
      firenew.(clustnum) = firingdata+k;
      l = l+1;
  end
    vals = decodeshitACC(timevector, firenew, vel, tdecode, t);
    [values median mean] = accerror(vals, vel);
    newerrors = [k, median, mean];
    errors(z,:) = newerrors
    z = z+1
    k = k+shift_increment;
end

figure
subplot(2,1,1)
plot(errors(:,1), errors(:,2));
title('medians')
subplot(2,1,2)
plot(errors(:,1), errors(:,3));
title('means')

f = errors;
