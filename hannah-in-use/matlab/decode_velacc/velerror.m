function f = velerror(decodedvel, pos)
%returns an error in cm/s for each decoded time. can also use for decoded acc

time = decodedvel(2,:);
decodedvel = decodedvel(1,:);
vel = velocity(pos);


alldiff = [];
closevel = [];
for i=1:length(time)
  [c index] = (min(abs(time(i)-vel(2,:))));
  closevel(end+1) = vel(1,index);
  diff = abs(decodedvel(i)-vel(1,index));
  alldiff(end+1) = diff;
end

f = [alldiff; time];
%f = closevel;
