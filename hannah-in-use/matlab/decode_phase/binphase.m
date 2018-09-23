function f = binphase(time, cueOn, tdecode)


  [c startindex] = min(abs(time-cueOn(1)));
  [c endindex] = min(abs(time-cueOn(end)));
  timevector = time(startindex:(endindex+(17*2000)));

  foodOn = cueOn+8;
  foodEnd = foodOn+8;
  cueOnindex=[];
  foodOnindex=[];
  foodEndindex=[];
  for k=1:length(cueOn)
      [c cueindex] = min(abs(time-cueOn(k)));
      [c foodindex] = min(abs(time-foodOn(k)));
      [c endindex] = min(abs(time-foodEnd(k)));
      cueOnindex(end+1) = cueindex;
      foodOnindex(end+1) = foodindex;
      foodEndindex(end+1) = endindex;
  end

  %finding times for intertrial
  k = 1;
  cueOnly = [];

  reward = [];

  intertrial = [];
  timeintertrial = 0;
  postcue = [];
  timepostcue = 0;
  while k <= length(cueOnindex)
      cue = time(cueOnindex(k):foodOnindex(k));
      cueOnly = horzcat(cueOnly, cue);

      food = time(foodOnindex(k):foodEndindex(k));
      reward = horzcat(reward, food);

  		%define start time as first cue starting
  		if k == 1
  				starting = cueOnindex(k);
  				timepostcue = time(foodEndindex(k):foodEndindex(k)+2000);
  		else

  				%using 18000 (9 seconds) here so you an also get the one second after where firing peaks
  				timeintertrial = timeintertrial + (time(cueOnindex(k))-time(foodEndindex(k-1))); %length of time
  				base = time(foodEndindex(k-1):cueOnindex(k)); %timestamps
  				intertrial = horzcat(intertrial, base); %totaltimestamps

  				%time post cue is just number of trials * 1 second
  		end

  k = k +1;
  end


t = tdecode;
t = 2000*t;
tm = 1;
phase = [];
times = [];
while tm <= length(timevector)-(rem(length(timevector), t))
  if length(intersect(timevector(tm:tm+t), intertrial)) == length(timevector(tm:tm+t))
      phase(end+1) = 3;
  elseif length(intersect(timevector(tm:tm+t), cueOnly)) == length(timevector(tm:tm+t))
      phase(end+1) = 1;
  elseif length(intersect(timevector(tm:tm+t), reward)) == length(timevector(tm:tm+t))
      phase(end+1) = 2;
  elseif length(intersect(timevector(tm:tm+t), intertrial)) > length(intersect(timevector(tm:tm+t), cueOnly))
      phase(end+1) = 3;
  elseif length(intersect(timevector(tm:tm+t), intertrial)) <= length(intersect(timevector(tm:tm+t), cueOnly))
      phase(end+1) = 1;
  elseif length(intersect(timevector(tm:tm+t), cueOnly)) > length(intersect(timevector(tm:tm+t), reward))
      phase(end+1) = 1;
  elseif length(intersect(timevector(tm:tm+t), cueOnly)) <= length(intersect(timevector(tm:tm+t), reward))
      phase(end+1) = 2;
  elseif length(intersect(timevector(tm:tm+t), reward)) > length(intersect(timevector(tm:tm+t), intertrial))
      phase(end+1) = 2;
  elseif length(intersect(timevector(tm:tm+t), reward)) <= length(intersect(timevector(tm:tm+t), intertrial))
      phase(end+1) = 3;
  else
      phase(end+1) = NaN
  end

  times(end+1) = timevector(tm);
  tm = tm+t;
end


f = [phase; times];
