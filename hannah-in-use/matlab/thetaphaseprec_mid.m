function f = thetaphaseprec_mid(cluster, pos, time, lfp, varargin)
  %unfilted LFP
  %returns all spike phases
  %put anything in varargin to get it by run

if length(lfp)~=length(time)
  warning('your time must be same as your lfp')
end
cluster;
ts = pos(:,1);
[cc indexmin] = min(abs(ts(1)-cluster));
[cc indexmax] = min(abs(ts(end)-cluster));
cluster = cluster(indexmin:indexmax);

[toreward, awayreward] = middletimes(pos, 1);

oldtime = (pos(:,1));
X = (pos(:,2));
%pos = assignpos(time, pos);
%asspos = assignposOLD(cluster, pos);

[oldtime,ia,ic] = unique(oldtime);

X = interp1(unique(oldtime), X(ia), cluster, 'pchip');


%do to reward first
torewardphase = [];
eventX = [];
k=1;

figure
while k<=length(toreward)
    [cc indexmin] = min(abs(toreward(k)-time));
    [cc indexmax] = min(abs(toreward(k+1)-time));
    currentlfp = lfp(indexmin:indexmax);
    currenttime = time(indexmin:indexmax);

    [cc indexmin] = min(abs(toreward(k)-cluster));
    [cc indexmax] = min(abs(toreward(k+1)-cluster));
    currentcluster = cluster(indexmin:indexmax);
    currentX = X(indexmin:indexmax);


    [kappa, phase] = spikethetaphase(currentcluster, currentlfp, currenttime, 1, 4);

    phase = rad2deg(phase);

    if length(varargin)>0
    subplot(ceil(length(toreward)./6), 3, (k+1)/2)
    scatter(currentX, phase)
    %axis([450 590 0 720])
    xlabel('X coordinate')
    ylabel('Phase')
    hold on
    else
    torewardphase = [torewardphase; phase];
    eventX = vertcat(eventX, currentX);
    end
    k = k+2;
end


%now away from reward
%{
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
%}

%av_to_reward = torewardkappa;
%av_away_reward = mean(awayrewardkappa(~isnan(awayrewardkappa)))

goodones = (~isnan(torewardphase));
torewardphase = torewardphase(goodones);
eventX = eventX(goodones);
f = [eventX'; torewardphase'];
