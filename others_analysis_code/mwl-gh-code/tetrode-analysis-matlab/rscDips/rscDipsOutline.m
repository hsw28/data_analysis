function rscDipsOutline()

% Establish state scoring
%  - State is: run | track | pause | groom | sleep | quietWake | deepSleep | REM
%  - Optional use of
%    - Hippocampal Theta/delta ratio
%    - Hippocampal frequency of ripples
%    - Tracker velocity
%    - EMG power
% 
% Collect examples of dips & ripples
%  - multiunit activity
%  - eeg
%  - filtered eeg (dip-band)
%  - Aligned with activity in HPC (ripples and replay)
% 
% Descriptive stats
%  - Dip length vs. behavior state
%  - upstate length vs. behavior state
%  - Average K-complex (triggered on dip starts/ends/centers)