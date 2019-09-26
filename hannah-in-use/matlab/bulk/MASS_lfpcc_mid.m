function [f notes] = MASS_lfpcc_mid(posstructure, timestructure, lfpstructureLS, lfpstructureHPC)
  %unfilted LFP
  %finds kappa for choice versus free in middle arm (directional)


LFPnamesLS = fieldnames(lfpstructureLS);
LFPnumLS = length(LFPnamesLS);

LFPnamesHPC = fieldnames(lfpstructureHPC);
LFPnumHPC = length(LFPnamesHPC);

%plots = ceil(spikenum./3);
output = {'cluster name'; 'mean CC to reward'; 'mean CC away from reward'};

numpoint = [];
allcaps =[];
previousdate = 0;
maxcc = [];
for k=1:LFPnumLS
  %LFPall.date_rat9_2018_02_07_lfp
    name = char(LFPnamesLS(k))
    currentLFPls = (lfpstructureLS.(name));
    %currentLFPls = thetafilt412(lfpstructureLS.(name));
    date = strsplit(name,'_lfp');
    date = char(date(1,1));
      % formats date to be same as in time structure: date_2015_08_01_time
      timeformateddate = strcat(date, '_time');
      % formats date to be same as in time structure: date_2015_08_01_position
      posformateddate = strcat(date, '_position');
      % formats lfp to be same as in lfp structure: date_2015_08_01_position
      lfpformateddate = strcat(date, '_lfp');

      currentLFPhpc = (lfpstructureHPC.(lfpformateddate));

      %currentLFPhpc = thetafilt412(lfpstructureHPC.(lfpformateddate));
      currentpos = posstructure.(posformateddate);
      currenttime = timestructure.(timeformateddate);

      [toreward, awayreward] = middletimes(currentpos, 1);

      torewardkappa = [];
      z=1;
      newlfpLS = [];
      newlfpHPC = [];
      newtime = [];
      meanphasetowards = [];
      devtowards = [];
      maxCCto = [];
      currentCC = [];
      while z<=length(toreward)
          [cc indexmin] = min(abs(toreward(z)-currenttime));
          [cc indexmax] = min(abs(toreward(z+1)-currenttime));
          newlfpLS = [currentLFPls(indexmin:indexmax)];
          newlfpHPC = [currentLFPhpc(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];
          currentCC(end+1) = coheres(newlfpLS, newlfpHPC, newtime, 4, 12);
          z = z+2;
      end

      maxCCto(end+1) = nanmean(currentCC);




      %now away from reward
      awayrewardkappa = [];
      z=1;
      newlfp = [];
      newtime = [];
      newcluster = [];
      meanphaseaway = [];
      devaway = [];
      maxCCaway = [];
      currentCC = [];
      while z<=length(awayreward)
          [cc indexmin] = min(abs(awayreward(z)-currenttime));
          [cc indexmax] = min(abs(awayreward(z+1)-currenttime));
          newlfpLS = [currentLFPls(indexmin:indexmax)];
          newlfpHPC = [currentLFPhpc(indexmin:indexmax)];
          newtime = [currenttime(indexmin:indexmax)];
          currentCC(end+1) = coheres(newlfpLS, newlfpHPC, newtime, 4, 12);
          z = z+2;
      end

      maxCCaway(end+1) = nanmean(currentCC);

      %av_to_reward = mean(torewardkappa(~isnan(torewardkappa)));
      %av_away_reward = mean(awayrewardkappa(~isnan(awayrewardkappa)));


      newdata = {name; maxCCto; maxCCaway};
      output = horzcat(output, newdata);
  end

  f = output';
save('CC_lfp.mat','f')
