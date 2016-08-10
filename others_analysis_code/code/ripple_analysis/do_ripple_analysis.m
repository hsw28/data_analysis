function do_ripple_analysis(varargin)
% This script finds .eeg files, imports them, turns the common-time samples
% into a cdat struct, filters for ripples, calculates ripple bouts, and
% makes movies of the bouts

% Run from directory containing .eeg files.
% Files must be named xxxxxxxxxxx.eeg (not xxxx.eeg.es, etc)
analysis_opt = do_ripple_analysis_arg(varargin);

if (analysis_opt.import)
