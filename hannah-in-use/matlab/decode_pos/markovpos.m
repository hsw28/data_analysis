function fun = markov(decodedmaxes, posData)
  %use maximum decoded
  % hidden markov decoding – transition matrix


  decoded = decodedmaxes;


  decodedtimes = decoded(4,:);
  decodedX = decoded(1,:);
  decodedY = decoded(2,:);

  x = posData(:,2);
  y = posData(:,3);

  vel = velocity(posData);
  assvel = assignvelOLD(decodedtimes, vel);


%different states
%state 1: left forced :    x < 500 y >= 540
%state 2: right forced arm    x < 500 y < 336 y >= 166
%state 3: first half (by forced) middle arm -- will be an elseif on the ys   x<645
%state 4: second half (by reward) middle arm -- will be an elseif on the ys  x>=645
%state 5: left reward end     x >= 780  y>=575
%state 6: left reward arm     x >=780   y<575 y>411
%state 7: right reward arm    x >=780   y>=172  y<370
%state 8: right reward end   x >=780   y<172

%{
x = posData(:,2);
y = posData(:,3);
%need time in each position for normalization
statecount = zeros(10,1);
for k=1:length(x)
  if vel(k) < 10
  if x(k)< 500 & y(k)>=540
    statecount(1) = statecount(1)+1;
  %2
  elseif x(k)< 500 &  y(k)>= 393 & y(k)< 540
    statecount(2) = statecount(2)+1;
  %3
  elseif x(k) < 500 & y(k) < 336 & y(k) >= 166
    statecount(3) = statecount(3)+1;
  %4
  elseif x(k)< 500 & y(k) < 166
    statecount(4) = statecount(4)+1;
  %7
  elseif x(k) >= 780 & y(k)>=575
    statecount(7) = statecount(7)+1;
  %8
  elseif x(k) >=780  & y(k)< 575 & y(k)> 411
    statecount(8) = statecount(8)+1;
  %9
  elseif x(k) >=780  & y(k)>=172  & y(k)< 370
    statecount(9) = statecount(9)+1;
  %10
  elseif x(k) >=780 & y(k)<172
    statecount(10) = statecount(10)+1;
    %5
    elseif x(k)< 645
      statecount(5) = statecount(5)+1;
    %6
    elseif x(k)>=645
      statecount(6) = statecount(6)+1;
  else
    fprintf('unclassified point at')
    x(k)
    y(k)
  end
end
end
%}

markov = zeros(8,8);  %first dimension is current position, second dimension is next position
x = decoded(1,:);
y = decoded(2,:);
for k=1:length(decodedtimes)-1
  c = 0; %current position
  f = 0; %future position
  if assvel(k) < 12
    %first current position
  if x(k)< 500 & y(k)>= 393
      c = 1;
  elseif x(k) < 500 & y(k) < 300
      c = 2;
    %5
    elseif x(k) >= 780 & y(k)>=575
      c=5;
    %6
    elseif x(k) >=780  & y(k)< 575 & y(k)> 411
      c=6;
    %7
    elseif x(k) >=780  & y(k)>=172  & y(k)< 370
      c=7;
    %8
    elseif x(k) >=780 & y(k)<172
      c=8;
      %3
      elseif x(k)< 645
        c=3;
      %4
      elseif x(k)>=645
        c=4;
    end
  %NOW FUTURE POSITION
  if x(k+1)< 500 & y(k+1)>=393
    f=1;
  elseif x(k+1) < 500 & y(k+1) < 300
    f=2;

  %5
  elseif x(k+1) >= 780 & y(k+1)>=575
    f=5;
  %6
  elseif x(k+1) >=780  & y(k+1)< 575 & y(k+1)> 411
    f=6;
  %7
  elseif x(k+1) >=780  & y(k+1)>=172  & y(k+1)< 370
    f=7;
  %8
  elseif x(k+1) >=780 & y(k+1)<172
    f=8;
    %3
    elseif x(k+1)< 645
      f=3;
    %4
    elseif x(k+1)>=645
      f=4;
  end

  markov(c,f) = markov(c,f)+1;   %assign state
  end
end

markov

%statecount = statecount/30; %for seconds
%now have matrix, and have to divide by occupancy and normalize to 1
for k=1:length(markov)
    %markov(k,:) = markov(k,:)./statecount(k);
    msum = sum(markov(k,:));
    div = 1./msum;
    markov(k,:) = markov(k,:)*div;
end

%fun = markov;

figure
xlabels = {'Forced Left', 'Forced Right', 'Middle Stem 1st half', 'Middle Stem 2nd half', 'Choice Left Arm', 'Left Reward Site', 'Choice Right Arm', 'Right Reward Site'};
ylabels = {'Forced Left', 'Forced Right', 'Middle Stem 1st half', 'Middle Stem 2nd half', 'Choice Left Arm', 'Left Reward Site', 'Choice Right Arm', 'Right Reward Site'};

h = heatmap(xlabels, ylabels, markov);
ylabel('Decoded Position at Time t')
xlabel('Decoded Position at Time t+1')
