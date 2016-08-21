function create_epochs(session_dir)
% processes mwl data files in session_dir/extracted_data into epochs
% creates session_dir/epochs/ and session_dir/epochs/<epoch_name> and
% session_dir/epochs/<epoch_name>/<tetrode_number>.  Creates links in the
% <tetrode_number> directory to the appropriate .tt and .pxyabw file in the
% extracted_data/ directory under session_dir/
%
% Also process the eeg files and position files. 
% .EEG files get unified into a single file with all samples across all
% channels synchronized. This file is then split based upon epochs and 
% saved under session_dir/epochs/<epoch_name>/eeg.mat
% .POS files get decoded and turned into diodes.p which is also split based
% upon epochs and placed in session_dir/epochs/<epoch_name>/diodes.p
%
% Extrenal Libraries Required:
%   MWLIO
%   fkPreProcessing (pos2diode.m)


% Give user option to Figure out EPOCHS 
answer = questdlg('Run xlcust3 to get Epoch Data?', 'Yes');
if strcmp(answer, 'Yes')
    grab_epochs_xclust(session_dir);
end;


% Create Epoch dir 
if ~exist(fullfile(session_dir, 'epochs/'), 'dir')
    system(['mkdir ' fullfile(session_dir, 'epochs/')]);
end

% create subdirs under session_dir/epochs/ 
disp('Creating epoch directories');
create_epoch_dirs(session_dir);

% create tetrode subdir under session_dir/epochs/<epoch_name>
% also creates link from extracted_data to tetrode_dirs (.tt .pxyabw)
disp('Creating epoch/<epoch>/tetrode directories');
create_tetrode_dirs(session_dir);

% merge and synchronize eeg file by epoch, save eeg under
% <epoch_name>/eeg.mat
disp('Downsampling and cutting EEG into epochs');
downsample_and_move_eeg(session_dir);  %not workig?!?!?!?


% convert pos to diodes
output = get_dir_names(fullfile(session_dir, 'extracted_data', '*.pos'));
pos_file = output{1};
disp('Converting pos file to diode file')
pos2diode(fullfile(session_dir, 'extracted_data', pos_file), fullfile(session_dir, 'extracted_data', 'diodes.p'));

% compute pos/head-dir/etc... from diodes.p split into into epochs, save 
% under <epoch_name>/position.p
disp('Convertion diode file to position file, cutting by epoch');
diode2p_lite(session_dir);


end