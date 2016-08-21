% fkPreProcessing Toolbox
% Version 0.2.7 26-Sep-2009
%
% Data extraction
%   super_process                - convience function for pre processing
%   extract_day                  - extract raw AD36 data files
%
% Data preprocessing
%   process_eeg                  - debuffer and downsample eeg files per epoch
%   process_events               - process event files
%   process_position             - script to process position data
%   describe_sources_and_signals - collect information about all sources and signals
%   process_video                - script to process video data
%
% Position processing
%   pos2diode                    - process raw position file and output diode position
%   raw2diode                    - compute diode coordinates from raw position data
%   correct_position             - check and correct diode position
%   process_behavior             - compute head position and direction
%   filtpos_jumps                - remove transient big jumps in data
%   filtpos_checkdiodedist       - filter data for inter diode distances that are too large
%   filtpos_checkspeed           - filter data for too high speed or acceleration
%   filtpos_gapinterp            - linearly interpolation of small gaps
%   filtpos_hdinterp             - diode position interpolation using head direction and diode distance
%   filtpos_interpolate          - interpolate diode data
%   imglabel                     - find groups of connected pixels in sparse image
%   diode_orient_gui             - explore head direction change
%
% Epoch processing
%   define_epochs                - define epochs in recording session
%
% EEG processing
%   debuffer_eeg_file            - unbuffer and resample .eeg files
%
% Video processing
%   index_videofile              - indexing of video file
%
% Source and signal processing
%   define_sources               - user defined sources
%   discover_signals             - find tetrode and eeg signals
%   connect_sources_and_signals  - helper function to associate signals with sources
%
% Misc
%   makesources                  - compile mex files
%   pcafeatures                  - compute principal component features
