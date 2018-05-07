function f= rewardtimes(pos, l)

  % tells you the time animal went to reward site and amount of time spent there
  % l is time in seconds you want animal to have to be in end to have it count

x = pos(:, 2);
y = pos(:, 3);
t = pos(:, 1);

k = 1;
i = 1;
n = 0;
nn = 0;
rewardentrance = [];
rewardlengths = [];
while k<=length(pos)
    % find when animal is at reward areas
    if (y(k) > 560 && x(k) > 750) | (y(k) < 180 & x(k) > 750)

      % looks to see when animal leaves area
      i = k;
      while ((y(i) > 560 && x(i) > 750) | (y(i) < 180 & x(i) > 750)) && i<length(pos)
        i=i+1;
      end


      %now t(k) is entrance, t(i) is exit
      % check to see if animal is there for over 15 seconds
      % if it is, add to reward time
      if t(i)-t(k) > l
          n = n+1; %counting how many times this happens
          nn = nn + (t(i)-t(k)); %adding up how much time animal spends there
          rewardlengths(end+1) = (t(i)-t(k));
          rewardentrance(end+1) = t(k);
      end
      k = i;
    end

k = k+1;
end

reward_entrances = n
reward_average_time = nn/n


f = [rewardentrance' rewardlengths'];
