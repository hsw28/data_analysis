function myStruct = MASS_crosscorrLSHPC(LSclusters, HPCclusters, pos)

%CAN ONLY DO FOR ONE DAY AT A TIME

[forcedarms, forcedpoint, middle, choicearms, freepoint] = posquadbin(pos, 0); %get different times
[toreward, awayreward] = middletimes(pos, 1); %get two middles

LSspikenames = fieldnames(LSclusters);
LSspikenum = length(LSspikenames);

HPCspikenames = fieldnames(HPCclusters);
HPCspikenum = length(HPCspikenames);

[n,index] = max([LSspikenum, HPCspikenum]);
if index == 1 %this means LS has more clusters
  fewerCLname = HPCspikenames;
  fewerCL = HPCclusters;
  moreCLname = LSspikenames;
  moreCL = LSclusters;
  numfewer = HPCspikenum;
%  moreValues = NaN(LSspikenum, 4) %cluster number, [forcedarms, choicearms, toreward, awayreward]
%  fewerValues = = NaN(LSspikenum, 4)
else
  moreCLname = HPCspikenames;
  moreCL = HPCclusters;
  fewerCLname = LSspikenames;
  numfewer = LSspikenum;
  fewerCL = LSclusters;
%  fewerValues = NaN(LSspikenum, 4)
%  moreValues = = NaN(LSspikenum, 4)
end


forcedmore = zeros(n,1);
forcedless = zeros(n,1);
timesforcedmore = NaN(n,10000);
timesforcedless = NaN(n,10000);

choicemore = zeros(n,1);
choiceless = zeros(n,1);
timeschoicemore = NaN(n,10000);
timeschoiceless = NaN(n,10000);

towardmore = zeros(n,1);
towardless = zeros(n,1);
timestowardmore = NaN(n,10000);
timestowardless = NaN(n,10000);

awaymore = zeros(n,1);
awayless = zeros(n,1);
timesawaymore = NaN(n,10000);
timesawayless = NaN(n,10000);


for k = 1:n %going from 1 up to length of fewer clusters
  if k<=numfewer

  fewername = char(fewerCLname(k));
  currentfewercluster = fewerCL.(fewername);
  else

  currentfewercluster = NaN;
  end

  morename = char(moreCLname(k));
  currentmorecluster = moreCL.(morename);

%%%%%%%%%%%%
%forced arms
  z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  k
  while z<=length(forcedarms)
      [cc indexmin] = min(abs(forcedarms(z)-currentmorecluster));
      [cc indexmax] = min(abs(forcedarms(z+1)-currentmorecluster));


    if indexmax-indexmin >0
      oldmore = forcedmore(k);
      forcedmore(k) = forcedmore(k)+length(currentmorecluster(indexmin:indexmax));
      timesforcedmore(k, oldmore+1:oldmore+(indexmax-indexmin)+1) = currentmorecluster(indexmin:indexmax)';
    end

      [cc indexmin] = min(abs(forcedarms(z)-currentfewercluster));
      [cc indexmax] = min(abs(forcedarms(z+1)-currentfewercluster));


      if indexmax-indexmin >0
        oldless = forcedless(k);
        forcedless(k) = forcedless(k)+length(currentfewercluster(indexmin:indexmax));
      timesforcedless(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
      currentcountless = indexmax-indexmin;
    end

      z = z+2;

  end

%%%%%%%%%%%%
%choicearms
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(choicearms)
    [cc indexmin] = min(abs(choicearms(z)-currentmorecluster));
    [cc indexmax] = min(abs(choicearms(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = choicemore(k);
      choicemore(k) = choicemore(k)+length(currentmorecluster(indexmin:indexmax));
    timeschoicemore(k,oldmore+1:oldmore+indexmax-indexmin+1) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;
  end

    [cc indexmin] = min(abs(choicearms(z)-currentfewercluster));
    [cc indexmax] = min(abs(choicearms(z+1)-currentfewercluster));

    if indexmax-indexmin >0
    oldless = choiceless(k);
    choiceless(k) = choiceless(k)+length(currentfewercluster(indexmin:indexmax));
    timeschoiceless(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end

%%%%
%middle toreward
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(toreward)
    [cc indexmin] = min(abs(toreward(z)-currentmorecluster));
    [cc indexmax] = min(abs(toreward(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = towardmore(k);
      towardmore(k) = towardmore(k) +length(currentmorecluster(indexmin:indexmax));
    timestowardmore(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;
  end

    [cc indexmin] = min(abs(toreward(z)-currentfewercluster));
    [cc indexmax] = min(abs(toreward(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = towardless(k);
      towardless(k) = towardless(k)+length(currentfewercluster(indexmin:indexmax));
    timestowardless(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end

%%%%%
%middle awayreward
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(awayreward)
    [cc indexmin] = min(abs(awayreward(z)-currentmorecluster));
    [cc indexmax] = min(abs(awayreward(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = awaymore(k);
      awaymore(k) = awaymore(k)+length(currentmorecluster(indexmin:indexmax));
    timesawaymore(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;

  end

    [cc indexmin] = min(abs(awayreward(z)-currentfewercluster));
    [cc indexmax] = min(abs(awayreward(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = awayless(k);
      awayless(k) = awayless(k)+length(currentfewercluster(indexmin:indexmax));
    timesawayless(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end

end

%now you have: forcedmore, choicemore, toward more, awaymore, and same for less. all of these are just the number

myStruct.fewername = fewerCLname;

forcedcorr = NaN(numfewer,1);
forcedmore;
forcedless;
stmore = [];
stless = [];
myStruct.morename_forced = {numfewer,1};
myStruct.forcedcorr = NaN(numfewer, 3);
for k=1:numfewer
    if forcedless(k)>50
    [cc indexmin] = min(abs(forcedmore-forcedless(k)));
    myStruct.morename_forced(k) = moreCLname(indexmin);
    currentforcedmore  = timesforcedmore(indexmin, (~isnan(timesforcedmore(indexmin,:))));
    currentforcedless  = timesforcedless(k, (~isnan(timesforcedless(k,:))));

    q=1;
    while q<=length(forcedarms)
    stmore = vertcat(stmore, spiketrain(currentforcedmore, [forcedarms(q), forcedarms(q+1)], .01));
    stless = vertcat(stless, spiketrain(currentforcedless, [forcedarms(q), forcedarms(q+1)], .01));
    q=q+2;
    end

    [maxval,maxindex] = max(crosscorr(stmore, stless, 'NumLags', 1000));

    shufflemore = datasample(stmore, length(stmore), 'Replace',false);
    shuffleless = datasample(stless, length(stless), 'Replace',false);

    shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 1000);
    shuffledcorr = shuffledcorr(maxindex);

    forcedcorr(k) = maxval - shuffledcorr;

    myStruct.forcedcorr(k,1) = maxval;
    myStruct.forcedcorr(k,2) = shuffledcorr;
    myStruct.forcedcorr(k,3) = maxval - shuffledcorr;
  else
    forcedcorr(k) = NaN;
    myStruct.forcedcorr(k,1) = NaN;
    myStruct.forcedcorr(k,2) = NaN;
    myStruct.forcedcorr(k,3) = NaN;
  end

    %forcedcorr(k) = max(slidingWindowCorr(stmore, stless, 1000, 10)) %for .005 bins, 1 second with 10ms overlapping
  end


  choicecorr = NaN(numfewer,1);
  stmore = [];
  stless = [];
  myStruct.choicecorr = NaN(numfewer, 3);
  myStruct.morename_choice = {numfewer,1};
  for k=1:numfewer
      if choiceless(k)>50
      [cc indexmin] = min(abs(choicemore-choiceless(k)));
      myStruct.morename_choice(k) = moreCLname(indexmin);
      currentchoicemore  = timeschoicemore(indexmin, (~isnan(timeschoicemore(indexmin,:))));

      currentchoiceless  = timeschoiceless(k, (~isnan(timeschoiceless(k,:))));

      q=1;
      while q<=length(choicearms)

      stmore = vertcat(stmore, spiketrain(currentchoicemore, [choicearms(q), choicearms(q+1)], .010));;
      stless = vertcat(stless, spiketrain(currentchoiceless, [choicearms(q), choicearms(q+1)], .01));
      q=q+2;
      end

      [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 1000));

      shufflemore = datasample(stmore, length(stmore), 'Replace',false);
      shuffleless = datasample(stless, length(stless), 'Replace',false);

      shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 1000);
      shuffledcorr = shuffledcorr(maxindex);

      choicecorr(k) = maxval - shuffledcorr;

      myStruct.choicecorr(k,1) = maxval;
      myStruct.choicecorr(k,2) = shuffledcorr;
      myStruct.choicecorr(k,3) = maxval - shuffledcorr;
    else
      choicecorr(k) = NaN;
      myStruct.choicecorr(k,1) = NaN;
      myStruct.choicecorr(k,2) = NaN;
      myStruct.choicecorr(k,3) = NaN;
    end
      %forcedcorr(k) = max(slidingWindowCorr(stmore, stless, 1000, 10)) %for .005 bins, 1 second with 10ms overlapping
    end


    towardcorr = NaN(numfewer,1);
    stmore = [];
    stless = [];
    myStruct.towardcorr = NaN(numfewer, 3);
    myStruct.morename_toward = {numfewer,1};
    for k=1:numfewer
        if towardless(k)>50
        [cc indexmin] = min(abs(towardmore-towardless(k)));
        myStruct.morename_toward(k) = moreCLname(indexmin);
        currenttowardmore  = timestowardmore(indexmin, (~isnan(timestowardmore(indexmin,:))));

        currenttowardless  = timestowardless(k, (~isnan(timestowardless(k,:))));

        q=1;
        while q<=length(toreward)
        stmore = vertcat(stmore, spiketrain(currenttowardmore, [toreward(q), toreward(q+1)], .01));
        stless = vertcat(stless, spiketrain(currenttowardless, [toreward(q), toreward(q+1)], .01));
        %timestart = toreward(q)
        %timeend = toreward(q+1)
        %summore = sum(spiketrain(currenttowardmore, [toreward(q), toreward(q+1)], .01))
        %someless = sum(spiketrain(currenttowardless, [toreward(q), toreward(q+1)], .01))
        q=q+2;
        end

        [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 1000));

        shufflemore = datasample(stmore, length(stmore), 'Replace',false);
        shuffleless = datasample(stless, length(stless), 'Replace',false);

        shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 1000);
        shuffledcorr = shuffledcorr(maxindex);
        towardcorr(k) = maxval - shuffledcorr;

        myStruct.towardcorr(k,1) = maxval;
        myStruct.towardcorr(k,2) = shuffledcorr;
        myStruct.towardcorr(k,3) = maxval - shuffledcorr;
      else
        towardcorr(k) = NaN;
        myStruct.towardcorr(k,1) = NaN;
        myStruct.towardcorr(k,2) = NaN;
        myStruct.towardcorr(k,3) = NaN;
      end

      end

      awaycorr = NaN(numfewer,1);
      stmore = [];
      stless = [];
      myStruct.awaycorr = NaN(numfewer, 3);
      myStruct.morename_away = {numfewer,1};
      for k=1:numfewer
        if awayless(k)>50
          [cc indexmin] = min(abs(awaymore-awayless(k)));
          myStruct.morename_away(k) = moreCLname(indexmin);
          currentawaymore  = timesawaymore(indexmin, (~isnan(timesawaymore(indexmin,:))));

          currentawayless  = timesawayless(k, (~isnan(timesawayless(k,:))));

          %[forcedarms, choicearms, toreward, awayreward]
          q=1;
          while q<=length(awayreward)
          stmore = vertcat(stmore, spiketrain(currentawaymore, [awayreward(q), awayreward(q+1)], .01));
          stless = vertcat(stless, spiketrain(currentawayless, [awayreward(q), awayreward(q+1)], .01));
          q=q+2;
          end


          [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 1000));

          shufflemore = datasample(stmore, length(stmore), 'Replace',false);
          shuffleless = datasample(stless, length(stless), 'Replace',false);

          shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 1000);
          shuffledcorr = shuffledcorr(maxindex);
          awaycorr(k) = maxval - shuffledcorr;

          myStruct.awaycorr(k,1) = maxval;
          myStruct.awaycorr(k,2) = shuffledcorr;
          myStruct.awaycorr(k,3) = maxval - shuffledcorr;
        else
          awaycorr(k) = NaN;
          myStruct.awaycorr(k,1) = NaN;
          myStruct.awaycorr(k,2) = NaN;
          myStruct.awaycorr(k,3) = NaN;


        end
        end


        myStruct;
        f =[forcedcorr, choicecorr, towardcorr, awaycorr];
        myStruct.summary = f;


  %forcedcorr
