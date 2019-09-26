function [torewardkappa, awayrewardkappa] = thetaphase_mid(cluster, pos, time, lfp)
  %unfilted LFP
  %returns the mean kappa away from and towards reward

if length(lfp)~=length(time)
  error('your time must be same as your lfp')
end

[toreward, awayreward] = middletimes(pos, 1);

%do to reward first
torewardkappa = [];
k=1;

while k<=length(toreward)
    [cc indexmin] = min(abs(toreward(k)-time));
    [cc indexmax] = min(abs(toreward(k+1)-time));
    currentlfp = lfp(indexmin:indexmax);
    currenttime = time(indexmin:indexmax);

    [cc indexmin] = min(abs(toreward(k)-cluster));
    [cc indexmax] = min(abs(toreward(k+1)-cluster));
    currentcluster = cluster(indexmin:indexmax);

    torewardkappa(end+1) = spikethetaphase(currentcluster, currentlfp, currenttime);
    k = k+2;
end


%now away from reward
awayrewardkappa = [];
k=1;
while k<=length(awayreward)
    [cc indexmin] = min(abs(awayreward(k)-time));
    [cc indexmax] = min(abs(awayreward(k+1)-time));
    currentlfp = lfp(indexmin:indexmax);
    currenttime = time(indexmin:indexmax);

    [cc indexmin] = min(abs(awayreward(k)-cluster));
    [cc indexmax] = min(abs(awayreward(k+1)-cluster));
    currentcluster = cluster(indexmin:indexmax);

    awayrewardkappa(end+1) = spikethetaphase(currentcluster, currentlfp, currenttime);
    k = k+2;
end

av_to_reward = mean(torewardkappa(~isnan(torewardkappa)))
av_away_reward = mean(awayrewardkappa(~isnan(awayrewardkappa)))
