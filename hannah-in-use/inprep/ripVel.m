function f = ripVel(notableTimes_fromFindRipLFP, posData, lfp_time, lfp_data_FILTERED, time_before)
%make sure notable times are set to start, peak, end [starts; peaks; ends]
%time before is how many seconds of movement before the ripple you want analyzed
%f = [ripstart; closestmove_dif; mean_vel; peakfreq];
%
%finds the last period of movement (you can change the movement threshold) before a ripple, averages the velocity for
%a user inputted number of seconds before (Maybe this should be changed to the movement period), and plots average ripple frequency against velocity
%only uses the first ripple in each stop period

lfp_data = lfp_data_FILTERED;
rips = notableTimes_fromFindRipLFP;
ripstart = rips(1,:);
rippeak = rips(2,:);
ripend = rips(3,:);

velthreshold= 12;

posData = fixpos(posData);
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
veltime = vel(2,:);
velspeed = vel(1,:);

k=1;
move = [];
curtime = [];

k=1;


while k<=length(vel)
  if k<=8
    if mean(vel(1,k-k+1:k+8))>velthreshold %half second (15 time stamps) increments
      move(end+1) = 1;
    else
      move(end+1) = 0; %give it a 0 if animal not moving, %give it a 1 if animal moving
    end
  elseif k>8 && k<=length(vel)-8
    if mean(vel(1,k-8:k+8))>velthreshold %half second (15 time stamps) increments
      move(end+1) = 1;
    else
      move(end+1) = 0; %give it a 0 if animal not moving, %give it a 1 if animal moving
    end
  elseif k>length(vel)-8
    if mean(vel(1,k-8:length(vel)))>velthreshold %half second (15 time stamps) increments
      move(end+1) = 1;
    else
      move(end+1) = 0; %give it a 0 if animal not moving, %give it a 1 if animal moving
    end
  end
    curtime(end+1) = vel(2,k);
    k = k+1;
  end



movingyn = [curtime; move];
weneed = length(find(move==0));
x = randsample(weneed,weneed).*2;
move(find(move==0)) = x;
[b, n] = RunLength(move);

%histogram(n(find(n>1)),'BinWidth', 1)


movingy = [];
for k = 1:length(n)
  if n(k)>30
    movingy(end+1) = sum(n(1:k));
  end
end

movingy = curtime(movingy);


% b = [8,9,10,11], n = [1,2,3,1]






%movingy = find(move==1);
%movingy = curtime(movingy); %just times for yes to moving


closestmove_dif = [];
mean_vel = [];
peakfreq = [];
peaks_per_time = [];
mean_vel_all = [];
curmovingyold = 0;
for k=1:length(ripstart)
  %want to find closest moving value BEFORE the ripple start
  curstart = ripstart(k);

  curmovingy = find(movingy<=curstart);
  if length(curmovingy)<1 %this means no moving time before ripple
    closestmove_dif(end+1) = NaN;
    mean_vel(end+1) = NaN;
    peaks_per_time(end+1) = NaN;
    mean_vel_all(end+1) = NaN;
    continue
  end

  curmovingy = (curmovingy(end)); %index of closest moving time
  curmoving_start = movingy(curmovingy); %time of closest moving time

  if curmovingyold==curmovingy %means we already have a ripple during this stop period
    closestmove_dif(end+1) = NaN;
    mean_vel(end+1) = NaN;
    peaks_per_time(end+1) = NaN;
      mean_vel_all(end+1) = NaN;
    continue
  end

                          %%%%%%%
  closestmove_dif(end+1) = curstart -curmoving_start; %difference between ripple start and moving time

  [val,idx_move1]=min(abs(veltime-curmoving_start)); %closest velocity to movment start
  moveperiod = curmoving_start-time_before;
  [val,idx_move2]=min(abs(veltime-moveperiod)); %closest velocity to movment period end

                          %%%%%%


  mean_vel(end+1) = nanmean(velspeed(idx_move2:idx_move1)); %average velocity for defined period


  %%%CAN ALSO FIND VEL FOR SET TIME BEOFRE IRRELEVANT OF MOVEMENT start
  [val,idx_move1]=min(abs(veltime-curstart)); %closest velocity to movment start
  moveperiod = curstart-time_before;
  [val,idx_move2]=min(abs(veltime-moveperiod));
  mean_vel_all(end+1)= nanmean(velspeed(idx_move2:idx_move1));

  %now to find the average frequency response magnitude of ripple



  [val,lfptime_start]=min(abs(lfp_time-ripstart(k)));
  [val,lfptime_end]=min(abs(lfp_time-ripend(k)));


  curLFP = lfp_data(lfptime_start:lfptime_end);

    L = length(curLFP);
%{
    avg = mean(curLFP);
    curLFP = curLFP - avg; %remove DC offset
    Fs = 2000; %data sampling rate
    Ts = 1/Fs;
    Fn = Fs/2;
    FT_af = fft(curLFP)/L;
    Fv = linspace(0, 1, fix(L/2)+1)*Fn;
    Iv = 1:numel(Fv);
    [Y,I] = max(abs(FT_af(Iv,1))*2);
    P1 = Fv(I);
      peakfreq(end+1) = P1;
    %}


  [pks,locs] = findpeaks(curLFP, 2000, 'MinPeakDistance', .0025);
  peaks_per_time(end+1) = length(pks)/(L/2000);

                          %%%%%%%
    curmovingyold = curmovingy;

  end


f = [ripstart; closestmove_dif; mean_vel; mean_vel_all; peaks_per_time];
figure
x = find(closestmove_dif<10);
scatter(f(3,x), f(5,x))
lm = fitlm(f(3,x), f(5,x), 'linear')

%figure
%scatter(f(4,:), f(5,:))
%lm = fitlm(f(4,:), f(5,:), 'linear')
