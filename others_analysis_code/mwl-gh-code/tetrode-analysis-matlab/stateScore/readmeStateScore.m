function readmeStateScore()

% Functions that take eeg, EMG, behavioral data, and output
% a map from state name to segment list
% 
% - States: run | track | pause | groom | sleep | quietWake | deepSleep | REM
% 
% Top-level:  function state = behavioralStates()