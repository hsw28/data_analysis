function f = quadrantvel(posData, vel)
%finds average velocity for each quadrant
%you dont need to enter vel data, can just enter it if you want to use decoded data. otherwise can figure out vel from pos in code. enter 0 if not entering vel. do NOT use assigned vel
%different states
%state 1: left forced end
%state 2: left forced arm
%state 3: right forced arm
%state 4: right forced end
%state 5: first half (by forced) middle arm -- will be an elseif on the ys   x<645
%state 6: second half (by reward) middle arm -- will be an elseif on the ys  x>=645
%state 7: left reward end     x >= 780  y>=575
%state 8: left reward arm     x >=780   y<575 y>411
%state 9: right reward arm    x >=780   y>=172  y<370
%state 10: right reward end   x >=780   y<172

if vel == 0
vel = velocity(posData);
vel = vel(1,:);
elseif size(vel,1)>2
vel = [vel(1,:); vel(2,:)];
vel = assignvelOLD(posData(:,1), vel);

end

if length(vel < length(posData))
x = posData(1:length(vel),2);
y = posData(1:length(vel),3);
else
  x = posData(:,2);
  y = posData(:,3);
  vel = vel(1:length(posData));
end

statecount = zeros(10,1);
velsum = zeros(10,1);
velall1 = [];
velall2 = [];
velall3 = [];
velall4 = [];
velall5 = [];
velall6 = [];
velall7 = [];
velall8 = [];
velall9 = [];
velall10 = [];
for k=1:length(x)
  if x(k)< 500 & y(k)>=540
    statecount(1) = statecount(1)+1;
    velsum(1) = velsum(1) + vel(k);
    velall1(end+1) = vel(k);
  %2
  elseif x(k)< 500 &  y(k)>= 393 & y(k)< 540
    statecount(2) = statecount(2)+1;
    velsum(2) = velsum(2) + vel(k);
    velall2(end+1) = vel(k);
  %3
  elseif x(k) < 500 & y(k) < 336 & y(k) >= 166
    statecount(3) = statecount(3)+1;
    velsum(3) = velsum(3) + vel(k);
    velall3(end+1) = vel(k);
  %4
  elseif x(k)< 500 & y(k) < 166
    statecount(4) = statecount(4)+1;
    velsum(4) = velsum(4) + vel(k);
    velall4(end+1) = vel(k);
  %7
  elseif x(k) >= 780 & y(k)>=575
    statecount(7) = statecount(7)+1;
    velsum(7) = velsum(7) + vel(k);
    velall7(end+1) = vel(k);
  %8
  elseif x(k) >=780  & y(k)< 575 & y(k)> 411
    statecount(8) = statecount(8)+1;
    velsum(8) = velsum(8) + vel(k);
    velall8(end+1) = vel(k);
  %9
  elseif x(k) >=780  & y(k)>=172  & y(k)< 370
    statecount(9) = statecount(9)+1;
    velsum(9) = velsum(9) + vel(k);
    velall9(end+1) = vel(k);
  %10
  elseif x(k) >=780 & y(k)<172
    statecount(10) = statecount(10)+1;
    velsum(10) = velsum(10) + vel(k);
    velall10(end+1) = vel(k);
    %5
    elseif x(k)< 645
      statecount(5) = statecount(5)+1;
      velsum(5) = velsum(5) + vel(k);
      velall5(end+1) = vel(k);
    %6
    elseif x(k)>=645
      statecount(6) = statecount(6)+1;
      velsum(6) = velsum(6) + vel(k);
      velall6(end+1) = vel(k);
  else
    fprintf('unclassified point at')
  end
end

velaverages = velsum ./ statecount;
stdev1 = std(velall1);
stdev2 = std(velall2);
stdev3 = std(velall3);
stdev4 = std(velall4);
stdev5 = std(velall5);
stdev6 = std(velall6);
stdev7 = std(velall7);
stdev8 = std(velall8);
stdev9 = std(velall9);
stdev10 = std(velall10);


stdevall = [stdev1 stdev2 stdev3 stdev4 stdev5 stdev6 stdev7 stdev8 stdev9 stdev10]
f = [velaverages'; stdevall];
