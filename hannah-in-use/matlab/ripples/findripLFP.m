
function [notabletimes, all] = findripLFP(unfilteredLFP, timevector, devAboveMean, posData, varargin);
%IF DONT HAVE VELOCITY PUT 0
%varargin = min ripple length
% finds ripples from eeg data by bandpass filtering, transforming, and then looking for signals >y dev above mean. returns a vector [ripple start; ripplepeak]
% uses position to only get ripples from when animal is not moving
% ex:
% function p = findrip(unfilteredLFP, timevector, devAboveMean, pos);
%CLIPS RIPPLES TO BE FROM MAZE STARTING TO 40 MIN AFTER MAZE

c = unfilteredLFP;
d = timevector;
y = devAboveMean;

if cell2mat(varargin) > 0
	minriplength = cell2mat(varargin);
else
minriplength = .03
end



if abs(length(unfilteredLFP)-length(timevector))>10
	error('YOUR TIME IS NOT THE LFP TIME')
end

if length(posData)>1

	posData = fixpos(posData);
	vel = velocity(posData);
	vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
	vel = [vel, [vel(2,end)+.1; 0]];

	[timestart start] = min(abs(vel(2,1)-timevector));
	[timefinish finish] = min(abs(vel(2,end)-timevector));
	timevector = timevector(start:finish);
	unfilteredLFP = unfilteredLFP(start:finish);

end

posDataOld = posData;




filtdata = ripfilt(c);


% filters data with bandpass filter between 100-300hz

% does a hilbert transformation on the data
h = hilbert(filtdata);
trans = abs(h);
d= d(1:length(trans));

trans = smoothdata(trans,'gaussian', 8);



% finds std devs above mean
mn = mean(trans);
st = std(trans);
m = mn + (st.*y); % this is the value LFP must be above

%also finds 6 std dev above mean to rule out huge things
big = mn + (st.*6);

%makes empty vector to hold times of ripples
rt=[];
peaktime=[];
starts = [];
ends = [];
alltime = [];



% permute through transformed data and find when data is Y std devs above mean
for k = 1:(size(trans))

	if trans(k)>m && trans(k)<big

		% we've found something above threshold, now need to find surrounding times when it's back at mean

		% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
		i = k;
		while i>0 && abs(trans(i)-mn) > (st./2) && i<length(d)
			i=i-1;
		end

		% looks to see when value returns to half a std dev above mean, this is the end of the ripple time
		j = k;
		while abs(trans(j)-mn) > (st./2) && j<length(trans) && j<length(d)
			j=j+1;
		end


		%adds to vector ripple start, trigger, and end times
		%start time is d(i);
		%end time is d(j);
		k = j;

		%only include events longer than 30ms

		if i>0 && d(j)-d(i) >= minriplength && d(j)-d(i) <= 1.018
			%making a vector with all the data points of the ripple
			pt=[];

			for n = i:j

				%goes through data and adds data (NOT TIME) to vector
				pt(end+1) = c(n);

			end

			% makes sure ripple isn't from a huge fluxtuation like the wire getting disconnected
			%peakpoint = max(pt);
			%if peakpoint < big
				[peak,index] = max(pt);
				index = index+i-1;
				peaktime(end+1) = d(index);
				starts(end+1) = d(i);
				ends(end+1) = d(j);


			%end
		end

	end
end


%vector should have all peak times after getting rid of duplicates
peaks=unique(peaktime);
starts = unique(starts);
ends = unique(ends);

alltimes = [];
for k = 1:length(starts)
  riptimes = find(d>= starts(k) & d<=ends(k));
	alltimes = horzcat(alltimes, d(riptimes));
end


notabletimes = [starts; peaks; ends];

if length(posData)>1
velstarts = [];
velpeaks = [];
velends = [];
for k=1:length(starts)
	[timestart start] = min(abs(vel(2,:)-starts(k)));


	if start-30>0 && start+30<=length(vel)
		if (nanmean(vel(1,start-30:start+30))<5)
		velstarts(end+1) = starts(k);
		velpeaks(end+1) = peaks(k);
		velends(end+1) = ends(k);
		end
	elseif start-30<0
		if (nanmean(vel(1,1:start+30))<5)
		velstarts(end+1) = starts(k);
		velpeaks(end+1) = peaks(k);
		velends(end+1) = ends(k);
		end
	elseif start+30>length(vel)
		if (nanmean(vel(1,start-30:end))<5)
		velstarts(end+1) = starts(k);
		velpeaks(end+1) = peaks(k);
		velends(end+1) = ends(k);
		end
	end


end
notabletimes = [velstarts; velpeaks; velends];
end

if length(notabletimes)>=1

posData = posDataOld;
SWRstart = notabletimes(1,:);
SWRend = notabletimes(3,:);

posstart = posData(1,1);
posend = posData(end,1);

[c startindex] = min(abs(SWRstart-posstart));
[c endindex] = min(abs(SWRend-(posend+40*60))); %40 min after run

notabletimes = notabletimes(:, startindex:endindex);
else
	notabletimes = NaN;
end



%notabletimes = [starts; ends];
%notabletimes = peaks;
all = alltimes;
