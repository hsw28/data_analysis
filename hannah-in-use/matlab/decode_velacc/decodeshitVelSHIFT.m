function f = decodeshitVelSHIFT(timevector, clusters, vel, tdecode, t, maxSHIFT, shift_increment)
%allows you to shift decoding to see most accurate

clustname = (fieldnames(clusters));
numclust = length(clustname)

errors = zeros(ceil(maxSHIFT*2./shift_increment)+1, 3);
k = -maxSHIFT;
z = 1;

while k<=maxSHIFT+shift_increment
  l = 1;
  while l <= numclust %subtract
      name = char(clustname(l));
      firingdata = clusters.(name);
      clustnum = strcat('c', num2str(l));
      firenew.(clustnum) = firingdata+k;
      l = l+1;
  end
    [vals probs vbin] = decodeshitVel(timevector, firenew, vel, tdecode, t);

    %THIS IS TO GET ERROR "LENGTH"
    [values median mean] = velerror(vals, vel);
    newerrors = [k, median, mean];
    errors(z,:) = newerrors

    %%%%this is to get accuracy
    %realbin = binVel(timevector, vel, tdecode, vbin);
    %realval = realbin(1,:);
    %wanted = find(realval>1);
    %realval(wanted) = 2;
    %decval = vals(3,:);
    %wanted = find(decval>1);
    %decval(wanted) = 2;
    %con = confusionmat(decval, realval)
    %zerosens = con(1,1)./length(find(realval==1));
    %movesens = con(2,2)./length(find(realval==2));
    %newerrors = [k,accur, zerosens];
    %totalcorrect = (con(1,1)+con(2,2))./length(find(realval>0));
    %newerrors = [k, zerosens, movesens, totalcorrect];
    %errors(z,:) = newerrors

    z = z+1
    k = k+shift_increment;
end

figure
subplot(2,1,1)
plot(errors(:,1), errors(:,2));
title('medians')
title('accuracy')
subplot(2,1,2)
plot(errors(:,1), errors(:,3));
title('means')
title('sensitivity to zero velocity')

f = errors;
