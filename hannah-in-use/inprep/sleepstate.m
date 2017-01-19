function ratio = sleepstate(data, time);
%function [rem, nonrem] = sleepstate(data, time);

% inputs are lfp and time
% ex:
% [sleep.rem, sleep.nonrem] = sleepstate(lfp, time);
%
% output is a matrix with REM and nonREM times
%

time = time';

deltadata = (deltafilt(data));
thetadata = (thetafilt(data));

powerdelta = smooth((deltadata.*deltadata), 2000);
powertheta = smooth((thetadata.*thetadata), 2000);

rem = [];
nonrem = [];
start = [];
ratio = [];

ratio = powertheta./powerdelta;

%i = 1;
%while i<=size(data, 1)
%	% identifying REM start
%	ratio(end+1) =  (powertheta)/sum(powerdelta);
%	i=i+1;
%end

%i=1;
%while i<=size(data, 1)-2000
%	% identifying REM start
%	if sum(powertheta(i:i+2000))/sum(powerdelta(i:i+2000)) > 2
%		rem(end+1) = time(i);
%	else
%     		nonrem(end+1) = time(i);
%	end
%i= i+1;
%end

%sleep = [rem; nonrem];
	



%To identify REM episodes, LFP traces were digitally bandpass filtered in the delta (2–4 Hz) and theta (6–10 Hz) bands, and power in each band was computed as the time-averaged squared amplitude of the filtered trace. REM episodes were identified as periods of elevated theta-delta power ratio (> 2.0). To examine correspondence between long duration patterns and to reduce the detection of false-positive correlations associated with short duration patterns, we limited our analysis to REM episodes longer than 60 s in duration. Sleep during these intervals was verified on videotape.
%Temporally Structured Replay of Awake Hippocampal Ensemble Activity during Rapid Eye Movement Sleep

%REM was identified as periods with an elevated ratio (averaged every 1 s) of hippocampal EEG power in the theta band (5–12 Hz) to overall power (1–475 Hz)
%Memory of Sequential Experience in the Hippocampus during Slow Wave Sleep 


