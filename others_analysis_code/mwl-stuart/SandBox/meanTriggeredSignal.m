function [waveSamples, sampTs, sampIdx] = ...
    meanTriggeredSignal(triggerTimes, ts, wave, win)

% either provide triggerSamples and Signal
% or
% provide trigger times, timestamps, signal

if isempty(triggerTimes)
    error('No trigger times provided');
end
if nargin<1
    error('Must provide atleast 2 arguments');
end
if nargin==2
    wave = ts;
    ts = 1:numel(wave);
    win = 100;
elseif nargin == 3
    error('Invalid number of arguments');
end
    
if ~isvector(triggerTimes)
    error('Trigger times cannot be a matrix');
end

if matrixCheck(win) 
    error('WIN cannot be a matrix!');
elseif isscalar(win) && win<=0 || numel( win ) > 2
    error('Invalid window, must be a positive scalar or 1x2 vector');
end    
if isscalar(win)
    win = [-win win];
end

if ~timestampCheck(ts)
    error('Irregular timestamps provided');
end

fs = timestamp2fs(ts);

win = round(win * fs);
win = win(1):win(2);
nSamp = numel(win);

trigIdx = interp1(ts, 1:numel(ts), triggerTimes, 'nearest');

trigIdx = trigIdx(:);

sampIdx = bsxfun(@plus, win, trigIdx);

badSamps = any( sampIdx < 1, 2) | any( sampIdx > numel(ts),2) | any(isnan(sampIdx),2);
sampIdx = sampIdx(~badSamps, :);

waveSamples = wave(sampIdx);

sampTs = win / fs;

end