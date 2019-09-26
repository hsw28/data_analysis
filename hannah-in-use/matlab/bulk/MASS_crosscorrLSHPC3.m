function myStruct = MASS_crosscorrLSHPC3(LSclusters, HPCclusters, pos)

%CAN ONLY DO FOR ONE DAY AT A TIME

%[toreward1, forcedpoint, middle, toreward2, freepoint] = posquadbin(pos, 0); %get different times
%[toreward3, awayreward1] = middletimes(pos, 1); %get two middles

[toreward1, awayreward1, toreward2, awayreward2, toreward3, awayreward3] = middletimes3(pos);



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
%  moreValues = NaN(LSspikenum, 4) %cluster number, [toreward1, toreward2, toreward3, awayreward1]
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









t1more = zeros(n,1);
t1less = zeros(n,1);
timest1more = NaN(n,10000);
timest1less = NaN(n,10000);

t2more = zeros(n,1);
t2less = zeros(n,1);
timest2more = NaN(n,10000);
timest2less = NaN(n,10000);

t3more = zeros(n,1);
t3less = zeros(n,1);
timest3more = NaN(n,10000);
timest3less = NaN(n,10000);

a1more = zeros(n,1);
a1less = zeros(n,1);
timesa1more = NaN(n,10000);
timesa1less = NaN(n,10000);

a2more = zeros(n,1);
a2less = zeros(n,1);
timesa2more = NaN(n,10000);
timesa2less = NaN(n,10000);

a3more = zeros(n,1);
a3less = zeros(n,1);
timesa3more = NaN(n,10000);
timesa3less = NaN(n,10000);

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

  while z<=length(toreward1)
      [cc indexmin] = min(abs(toreward1(z)-currentmorecluster));
      [cc indexmax] = min(abs(toreward1(z+1)-currentmorecluster));


    if indexmax-indexmin >0
      oldmore = t1more(k);
      t1more(k) = t1more(k)+length(currentmorecluster(indexmin:indexmax));
      timest1more(k, oldmore+1:oldmore+(indexmax-indexmin)+1) = currentmorecluster(indexmin:indexmax)';
    end

      [cc indexmin] = min(abs(toreward1(z)-currentfewercluster));
      [cc indexmax] = min(abs(toreward1(z+1)-currentfewercluster));


      if indexmax-indexmin >0
        oldless = t1less(k);
        t1less(k) = t1less(k)+length(currentfewercluster(indexmin:indexmax));
      timest1less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
      currentcountless = indexmax-indexmin;
    end

      z = z+2;

  end

%%%%%%%%%%%%
%toreward2
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(toreward2)
    [cc indexmin] = min(abs(toreward2(z)-currentmorecluster));
    [cc indexmax] = min(abs(toreward2(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = t2more(k);
      t2more(k) = t2more(k)+length(currentmorecluster(indexmin:indexmax));
    timest2more(k,oldmore+1:oldmore+indexmax-indexmin+1) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;
  end

    [cc indexmin] = min(abs(toreward2(z)-currentfewercluster));
    [cc indexmax] = min(abs(toreward2(z+1)-currentfewercluster));

    if indexmax-indexmin >0
    oldless = t2less(k);
    t2less(k) = t2less(k)+length(currentfewercluster(indexmin:indexmax));
    timest2less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end

%%%%
%middle toreward3
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(toreward3)
    [cc indexmin] = min(abs(toreward3(z)-currentmorecluster));
    [cc indexmax] = min(abs(toreward3(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = t3more(k);
      t3more(k) = t3more(k) +length(currentmorecluster(indexmin:indexmax));
    timest3more(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;
  end

    [cc indexmin] = min(abs(toreward3(z)-currentfewercluster));
    [cc indexmax] = min(abs(toreward3(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = t3less(k);
      t3less(k) = t3less(k)+length(currentfewercluster(indexmin:indexmax));
    timest3less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end

%%%%%
%middle awayreward1
z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(awayreward1)
    [cc indexmin] = min(abs(awayreward1(z)-currentmorecluster));
    [cc indexmax] = min(abs(awayreward1(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = a1more(k);
      a1more(k) = a1more(k)+length(currentmorecluster(indexmin:indexmax));
    timesa1more(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;

  end

    [cc indexmin] = min(abs(awayreward1(z)-currentfewercluster));
    [cc indexmax] = min(abs(awayreward1(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = a1less(k);
      a1less(k) = a1less(k)+length(currentfewercluster(indexmin:indexmax));
    timesa1less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end



z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(awayreward2)
    [cc indexmin] = min(abs(awayreward2(z)-currentmorecluster));
    [cc indexmax] = min(abs(awayreward2(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = a2more(k);
      a2more(k) = a2more(k)+length(currentmorecluster(indexmin:indexmax));
    timesa2more(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;

  end

    [cc indexmin] = min(abs(awayreward2(z)-currentfewercluster));
    [cc indexmax] = min(abs(awayreward2(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = a2less(k);
      a2less(k) = a2less(k)+length(currentfewercluster(indexmin:indexmax));
    timesa2less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end



z = 1;
  currentcountmore = 1;
  currentcountless = 1;
  while z<=length(awayreward3)
    [cc indexmin] = min(abs(awayreward3(z)-currentmorecluster));
    [cc indexmax] = min(abs(awayreward3(z+1)-currentmorecluster));

    if indexmax-indexmin >0
      oldmore = a3more(k);
      a3more(k) = a3more(k)+length(currentmorecluster(indexmin:indexmax));
    timesa3more(k,oldmore+1:oldmore+1+indexmax-indexmin) = currentmorecluster(indexmin:indexmax)';
    currentcountmore = indexmax-indexmin;
  end

    [cc indexmin] = min(abs(awayreward3(z)-currentfewercluster));
    [cc indexmax] = min(abs(awayreward3(z+1)-currentfewercluster));

    if indexmax-indexmin >0
      oldless = a3less(k);
      a3less(k) = a3less(k)+length(currentfewercluster(indexmin:indexmax));
    timesa3less(k,oldless+1:oldless+1+indexmax-indexmin) = currentfewercluster(indexmin:indexmax)';
    currentcountless = indexmax-indexmin;
  end

    z = z+2;
  end
end
timesa3more(1:20);


%now you have: t1more, t2more, toward more, a1more, and same for less. all of these are just the number

toreward1corr = NaN(numfewer,1);
t1more;
t1less;
stmore = [];
stless = [];
myStruct.toreward1 = NaN(numfewer, 3);

%%%%%%%%%%%%%toward 1
for k=1:numfewer
    if t1less(k)>15
    [cc indexmin] = min(abs(t1more-t1less(k)));

    currentt1more  = timest1more(indexmin, (~isnan(timest1more(indexmin,:))));
    currentt1less  = timest1less(k, (~isnan(timest1less(k,:))));

    q=1;
    while q<=length(toreward1)
if sum(isnan(currentt1more))==0 &  sum(isnan(currentt1less))==0
    stmore = vertcat(stmore, spiketrain(currentt1more, [toreward1(q), toreward1(q+1)], .01));
    stless = vertcat(stless, spiketrain(currentt1less, [toreward1(q), toreward1(q+1)], .01));
  end
    q=q+2;
    end

    [maxval,maxindex] = max(crosscorr(stmore, stless, 'NumLags', 200));

    shufflemore = datasample(stmore, length(stmore), 'Replace',false);
    shuffleless = datasample(stless, length(stless), 'Replace',false);

    shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 200);
    shuffledcorr = shuffledcorr(maxindex);

    toreward1corr(k) = maxval - shuffledcorr;

    myStruct.toreward1corr(k,1) = maxval;
    myStruct.toreward1corr(k,2) = shuffledcorr;
    myStruct.toreward1corr(k,3) = maxval - shuffledcorr;
  else
    toreward1corr(k) = NaN;
    myStruct.toreward1corr(k,1) = NaN;
    myStruct.toreward1corr(k,2) = NaN;
    myStruct.toreward1corr(k,3) = NaN;
  end

    %toreward1(k) = max(slidingWindowCorr(stmore, stless, 1000, 10)) %for .005 bins, 1 second with 10ms overlapping
  end


%%%%%%%%%%%%%toward 2
  toreward2corr = NaN(numfewer,1);
  stmore = [];
  stless = [];
  myStruct.toreward2 = NaN(numfewer, 3);
  for k=1:numfewer
      if t2less(k)>15
      [cc indexmin] = min(abs(t2more-t2less(k)));

      currentt2more  = timest2more(indexmin, (~isnan(timest2more(indexmin,:))));

      currentt2less  = timest2less(k, (~isnan(timest2less(k,:))));

      q=1;
      while q<=length(toreward2)
if sum(isnan(currentt2more))==0 &  sum(isnan(currentt2less))==0
      stmore = vertcat(stmore, spiketrain(currentt2more, [toreward2(q), toreward2(q+1)], .010));
      stless = vertcat(stless, spiketrain(currentt2less, [toreward2(q), toreward2(q+1)], .01));
    end
      q=q+2;
      end
      length(stmore)
      [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 169));

      shufflemore = datasample(stmore, length(stmore), 'Replace',false);
      shuffleless = datasample(stless, length(stless), 'Replace',false);

      shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 169);
      shuffledcorr = shuffledcorr(maxindex);

      toreward2corr(k) = maxval - shuffledcorr;

      myStruct.toreward2corr(k,1) = maxval;
      myStruct.toreward2corr(k,2) = shuffledcorr;
      myStruct.toreward2corr(k,3) = maxval - shuffledcorr;
    else
      toreward2corr(k) = NaN;
      myStruct.toreward2corr(k,1) = NaN;
      myStruct.toreward2corr(k,2) = NaN;
      myStruct.toreward2corr(k,3) = NaN;
    end
      %toreward1(k) = max(slidingWindowCorr(stmore, stless, 1000, 10)) %for .005 bins, 1 second with 10ms overlapping
    end

%%%%%%%%%%%%%toward 3
    toreward3corr = NaN(numfewer,1);
    stmore = [];
    stless = [];
    myStruct.toreward3 = NaN(numfewer, 3);
    for k=1:numfewer
        if t3less(k)>15
        [cc indexmin] = min(abs(t3more-t3less(k)));

        currentt3more  = timest3more(indexmin, (~isnan(timest3more(indexmin,:))));

        currentt3less  = timest3less(k, (~isnan(timest3less(k,:))));

        q=1;
        while q<=length(toreward3)
          if sum(isnan(currentt3more))==0 &  sum(isnan(currentt3less))==0
        stmore = vertcat(stmore, spiketrain(currentt3more, [toreward3(q), toreward3(q+1)], .01));
        stless = vertcat(stless, spiketrain(currentt3less, [toreward3(q), toreward3(q+1)], .01));
        %timestart = toreward3(q)
        %timeend = toreward3(q+1)
        %summore = sum(spiketrain(currentt3more, [toreward3(q), toreward3(q+1)], .01))
        %someless = sum(spiketrain(currentt3less, [toreward3(q), toreward3(q+1)], .01))
      end
        q=q+2;
        end

        [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 200));

        shufflemore = datasample(stmore, length(stmore), 'Replace',false);
        shuffleless = datasample(stless, length(stless), 'Replace',false);

        shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 200);
        shuffledcorr = shuffledcorr(maxindex);
        toreward3corr(k) = maxval - shuffledcorr;

        myStruct.toreward3corr(k,1) = maxval;
        myStruct.toreward3corr(k,2) = shuffledcorr;
        myStruct.toreward3corr(k,3) = maxval - shuffledcorr;
      else
        toreward3corr(k) = NaN;
        myStruct.toreward3corr(k,1) = NaN;
        myStruct.toreward3corr(k,2) = NaN;
        myStruct.toreward3corr(k,3) = NaN;
      end
      end

%%%%%%%%%%%%%away 1
      awayreward1corr = NaN(numfewer,1);
      stmore = [];
      stless = [];
      myStruct.awayreward1 = NaN(numfewer, 3);
      for k=1:numfewer
        if a1less(k)>15
          [cc indexmin] = min(abs(a1more-a1less(k)));

          currenta1more  = timesa1more(indexmin, (~isnan(timesa1more(indexmin,:))));

          currenta1less  = timesa1less(k, (~isnan(timesa1less(k,:))));

          %[toreward1, toreward2, toreward3, awayreward1]
          q=1;
          while q<=length(awayreward1)
            if sum(isnan(currenta1more))==0 &  sum(isnan(currenta1less))==0
          stmore = vertcat(stmore, spiketrain(currenta1more, [awayreward1(q), awayreward1(q+1)], .01));
          stless = vertcat(stless, spiketrain(currenta1less, [awayreward1(q), awayreward1(q+1)], .01));
        end
          q=q+2;

          end


          [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 200));

          shufflemore = datasample(stmore, length(stmore), 'Replace',false);
          shuffleless = datasample(stless, length(stless), 'Replace',false);

          shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 200);
          shuffledcorr = shuffledcorr(maxindex);
          awayreward1corr(k) = maxval - shuffledcorr;

          myStruct.awayreward1corr(k,1) = maxval;
          myStruct.awayreward1corr(k,2) = shuffledcorr;
          myStruct.awayreward1corr(k,3) = maxval - shuffledcorr;
        else
          awayreward1corr(k) = NaN;
          myStruct.awayreward1corr(k,1) = NaN;
          myStruct.awayreward1corr(k,2) = NaN;
          myStruct.awayreward1corr(k,3) = NaN;


        end
        end

%%%%%%%%%%%%%away 2
        awayreward2corr = NaN(numfewer,1);
        stmore = [];
        stless = [];
        myStruct.awayreward2 = NaN(numfewer, 3);
        for k=1:numfewer
          if a2less(k)>15
            [cc indexmin] = min(abs(a2more-a2less(k)));

            currenta2more  = timesa2more(indexmin, (~isnan(timesa2more(indexmin,:))));

            currenta2less  = timesa2less(k, (~isnan(timesa2less(k,:))));

            %[toreward1, toreward2, toreward3, awayreward1]
            q=1;
            while q<=length(awayreward2)
              if sum(isnan(currenta2more))==0 &  sum(isnan(currenta2less))==0
            stmore = vertcat(stmore, spiketrain(currenta2more, [awayreward2(q), awayreward2(q+1)], .01));
            stless = vertcat(stless, spiketrain(currenta2less, [awayreward2(q), awayreward2(q+1)], .01));
          end
            q=q+2;

            end


            [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 200));

            shufflemore = datasample(stmore, length(stmore), 'Replace',false);
            shuffleless = datasample(stless, length(stless), 'Replace',false);

            shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 200);
            shuffledcorr = shuffledcorr(maxindex);
            awayreward2corr(k) = maxval - shuffledcorr;

            myStruct.awayreward2corr(k,1) = maxval;
            myStruct.awayreward2corr(k,2) = shuffledcorr;
            myStruct.awayreward2corr(k,3) = maxval - shuffledcorr;
          else
            awayreward2corr(k) = NaN;
            myStruct.awayreward2corr(k,1) = NaN;
            myStruct.awayreward2corr(k,2) = NaN;
            myStruct.awayreward2corr(k,3) = NaN;


          end
          end

%%%%%%%%%%%%%away 3
          awayreward3corr = NaN(numfewer,1);
          stmore = [];
          stless = [];
          myStruct.awayreward3 = NaN(numfewer, 3);
          awayreward3;
          for k=1:numfewer

            if a3less(k)>15

              [cc indexmin] = min(abs(a3more-a3less(k)));

              currenta3more  = timesa3more(indexmin, (~isnan(timesa3more(indexmin,:))));

              currenta3less  = timesa3less(k, (~isnan(timesa3less(k,:))));

              %[toreward1, toreward2, toreward3, awayreward1]
              q=1;
              while q<=length(awayreward3)
              if sum(isnan(currenta3more))==0 &  sum(isnan(currenta3less))==0

              stmore = vertcat(stmore, spiketrain(currenta3more, [awayreward3(q), awayreward3(q+1)], .01));
              stless = vertcat(stless, spiketrain(currenta3less, [awayreward3(q), awayreward3(q+1)], .01));
            end
              q=q+2;
              end


              [maxval,maxindex]  = max(crosscorr(stmore, stless, 'NumLags', 200));

              shufflemore = datasample(stmore, length(stmore), 'Replace',false);
              shuffleless = datasample(stless, length(stless), 'Replace',false);

              shuffledcorr = crosscorr(shufflemore, shuffleless, 'NumLags', 200);
              shuffledcorr = shuffledcorr(maxindex);
              awayreward3corr(k) = maxval - shuffledcorr;

              myStruct.awayreward3corr(k,1) = maxval;
              myStruct.awayreward3corr(k,2) = shuffledcorr;
              myStruct.awayreward3corr(k,3) = maxval - shuffledcorr;
            else
              awayreward3corr(k) = NaN;
              myStruct.awayreward3corr(k,1) = NaN;
              myStruct.awayreward3corr(k,2) = NaN;
              myStruct.awayreward3corr(k,3) = NaN;


            end
            end

        myStruct =[toreward1corr, toreward2corr, toreward3corr, awayreward1corr, awayreward2corr, awayreward3corr]


  %toreward1
