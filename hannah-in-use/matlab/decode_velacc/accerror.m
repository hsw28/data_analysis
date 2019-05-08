function [values median_is mean_is] = accerror(decodedacc, acc, vbin)
%returns an error in cm/s for each decoded time. can also use for decoded acc

time = decodedacc(2,:);
decodedacc = decodedacc(1,:);


%get acc lower 5 percent range

binacc = bintheta(acc(1,:), .5, 0, 30);
numwewant = length(binacc)*.05;
[N,EDGES] = histcounts(binacc,length(binacc));
k = length(N);
z = 0;
while z<numwewant
  z = z+N(k);
  k = k-1;
end
lim = EDGES(k)

alldiff = [];
closeacc = [];
for i=1:length(time)
  [c index] = (min(abs(time(i)-acc(2,:))));
  closeacc(end+1) = acc(1,index);

  %FOR ONLY GETTING NUMS IN ACC RANGE YOU WANT
  if abs(acc(1,index))<100 && abs(acc(1,index))>20
    diff = abs(decodedacc(i)-acc(1,index)); %keep this line always
  else
    diff = NaN;
  end


%  if (closeacc(end)) > vbin(end)
%    highestvel = find(vel(1,:)>vbin(end));
%    highestvel = median(vel(1,highestvel));
%    alldiff(end+1) = highestvel;
%  elseif (closeacc(end)) < vbin(1)
%    lowestvel = find(vel(1,:)<vbin(1));
%    lowestvel = median(vel(1,lowestvel));
%    vnew(bin) = lowestvel;

  if abs(closeacc(end))<=lim
    alldiff(end+1) = diff;
  else
    alldiff(end+1) = NaN;
  end
end
realacc = closeacc;

%25-100

values = [alldiff; realacc; time];


temp2 = values(1,:);
t = ~isnan(temp2);
temp2 = temp2(t);
mean_is = mean(temp2)
median_is = median(temp2)

%f = closeacc;
