function thingy = cohVsFiringRate(coh,time, firingdata, L)
% Takes coherence data, timestamps, cluster data, and window size (in samples)
% coherence data must be in form [x,2] with 2 being coherence then time
%
% Produces plots that relate Firing Rate in window to coherence
% in window
% length of the time window is determined by actual sampling rate and
% integer # of window samples. There is a print statement that returns
% window length in seconds
% cohrVsFiringRate(lfpmaze19.data,lfpmaze19.timestamp*7.75e-2,[mazet19c3;mazet19c4;mazet29c1]*7.75e-2,350);


start = min(time);
ending = max(time);
Fs = 2000;
t = L/Fs
r = mua_rate(firingdata,start,ending,t); %outputs r = [time_v; rate];
rate = r(2,:);

assigncoh = assignvel(r(1,:), coh);

times = r(:,1);
fastest = max(rate);

figure
size(coh)
size(rate/t)
scatter(assigncoh,rate/t)
xlabel('Theta Power Ratio');
ylabel('Firing rate/Sec.');
average = zeros(fastest+1,1);
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);
for i = 0:fastest
     subset = coh(rate == i);
     if length(subset) < threshold
         average(i+1) = NaN;
         deviation(i+1) = NaN;
     else
        average(i+1) = mean(subset);
        deviation(i+1) = std(subset,1);
     end
end

% figure
% errorbar((0:fastest)/t,average,deviation,'o')
% xlabel('Firing rate');
% ylabel('Average Theta Power Ratio');

figure
scatter(average,(0:fastest)/t)
xlabel('Average Coherence');
ylabel('Firing rate/Sec.');
lsline
% figure
% scatter(deviation, (0:fastest)/t)
% xlabel('Deviation of Theta Power Ratio');
% ylabel('Firing rate/Sec');
thingy = [average,deviation,(0:fastest)'/t];
