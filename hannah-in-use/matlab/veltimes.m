function f= veltimes(vel, pos, v, l)

  % tells you the time animal was below a particular velocity v
  % l is time in seconds you want animal to have to be in end to have it count

x = pos(:, 2);
y = pos(:, 3);

t = vel(2,:);
vel = vel(1,:);
k = 1;
i = 1;
n = 0;
nn = 0;
rewardentrance = [];
rewardlengths = [];
while k<=length(vel)
    % find when animal is at reward areas
    if (vel(k)<v) && x(k) < 750 | (y(k) < 560 && y(k) > 180)

      % looks to see when animal leaves area
      i = k;
      while vel(i)<v && i<length(vel)
        i=i+1;
      end


      %now t(k) is entrance, t(i) is exit
      % check to see if animal is there for over l seconds
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
