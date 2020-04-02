function [values median_is mean_is] = velerror(decodedvel, vel)
%returns an error in cm/s for each decoded time. can also use for decoded acc

time = decodedvel(2,:);
decodedvel = decodedvel(1,:);
%vel = velocity(pos);


%get velocity lower 5 percent range
binacc = bintheta(vel(1,:), .5, 0, 30);
numwewant = length(binacc)*.05;
[N,EDGES] = histcounts(binacc,length(binacc));
k = length(N);
z = 0;
while z<numwewant
  z = z+N(k);
  k = k-1;
end
lim = EDGES(k);

alldiff = [];
closevel = [];
for i=1:length(time)
  [c index] = (min(abs(time(i)-vel(2,:))));
  closevel(end+1) = vel(1,index);

  %%for one section
  if vel(1,index)>10 & vel(1,index)<30
    diff = abs(decodedvel(i)-vel(1,index)); %%KEEP IN
  else
    diff = NaN;
  end

  if closevel(end)<=lim
    alldiff(end+1) = diff;
  else
    alldiff(end+1) = NaN;
  end
end

realvel = closevel;
values = [alldiff; realvel; time];

temp2 = values(1,:);

mean_is = nanmean(temp2);
median_is = nanmedian(temp2);

%f = closevel;
