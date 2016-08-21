function tar_files_for_transfer(session_dir, data_path)
%
%   TAR_EPOCHS(SESSION_DIR, DATA_PATH) creates a tar.gz of all the user created files
%   under session dir. 
%   Because tar includes the path and each user might store the data in
%   different locations DATA_PATH is used to remove the proceeding
%   directories from session_dir preventing unwanted file collisions
%
%   Example: 
%       SESSION_DIR = /home/<user>/data/disk1/animalID/day#
%       DATA_PATH   = /home/<user>/data/disk1/
%
%   the tar file will have a base dir of animalID/day#
%
%   User generated files included:
%   session_dir/sources.mat
%   session_dir/signals.mat
%   session_dir/valid_eeg_chans.mat
%   session_dir/epochs/epochs.def
%   session_dir/epochs/<epoch_name>/good_cells.mat
%   session_dir/epochs/<epoch_name>/linear_position.p
%   session_dir/epochs/<epoch_name>/<tetrode_dir>/cl-*
%   session_dir/epochs/<epoch_name>/<tetrode_dir>/cbfile
%   session_dir/epochs/<epoch_name>/<tetrode_dir>/waveform-*
%
%   Written by Stuart Layton, 2009, MWL, MIT
%   slayton@mit.edu

file_list = {};
n_files = 0;

if ~strcmp(data_path(end), '/')
    data_path=[data_path, '/'];
end

base_dir = session_dir;
if strcmp(base_dir(1:length(data_path)), data_path) % remove /home/user/<data> path
    base_dir = base_dir(length(data_path)+1:end);
end
names = get_dir_names(fullfile(session_dir, '*.mat'));

for i=1:length(names)
    if strcmp(names{i}, 'sources.mat') || strcmp(names{i}, 'signals.mat') ...
            || strcmp(names{i}(1:7), 'cl_link') 
        file = names{i};
        n_files = n_files+1;
        file_list{n_files} = fullfile(base_dir, file);
    end
end;

if exist(fullfile(session_dir, 'valid_eeg_chans.mat'),'file')
    n_files = n_files +1;
    file_list{n_files} = fullfile(base_dir, 'valid_eeg_chans.mat');
end
if exist(fullfile(session_dir, 'epochs', 'epochs.def'),'file')
    n_files = n_files +1;
    file_list{n_files} = fullfile(base_dir, 'epochs', 'epochs.def');
    
    
    epochs = load_epochs(session_dir);
    
  
    for i = 1:length(epochs)  % get files names from each epoch
        if exist(fullfile( session_dir, 'epochs', epochs{i}, 'good_cells.mat'),'file')
            n_files = n_files +1;
            file_list{n_files} = fullfile(base_dir, 'epochs', epochs{i}, 'good_cells.mat');
        end
            
        tt_dirs = get_dir_names(fullfile(session_dir, 'epochs', epochs{i}, 't*'));
        for j = 1:length(tt_dirs)  % get file names from each tetrode dir
            cl_files = get_dir_names(fullfile(session_dir, 'epochs', epochs{i}, tt_dirs{j}, epochs{i},'cl*'));
            if ~isempty(cl_files)
                n_files = n_files +1;
                file_list{n_files} = fullfile(base_dir, 'epochs', epochs{i}, tt_dirs{j},epochs{i}, 'cl*'); %#ok
            end
            
            wave_files = get_dir_names(fullfile(session_dir, 'epochs', epochs{i}, tt_dirs{j}, 'wave*'));
            if ~isempty(wave_files)
                n_files = n_files +1;
                file_list{n_files} = fullfile(base_dir, 'epochs', epochs{i}, tt_dirs{j}, 'wave*');
            end
            
            bound_files = get_dir_names(fullfile(session_dir, 'epochs', epochs{i}, tt_dirs{j}, 'bound*'));
            if ~isempty(bound_files)
                n_files = n_files +1;
                file_list{n_files} = fullfile(base_dir, 'epochs', epochs{i}, tt_dirs{j}, 'bound*');
            end     
        end
        if exist(fullfile(session_dir, 'epochs', epochs{i}, 'linear_position.p'), 'file')
            n_files = n_files+1;
            file_list{n_files} = fullfile(base_dir, 'epochs', epochs{i}, 'linear_position.p');
        end
    end
end

% Create tar.gz archive
input_files = [];
for i=1:length(file_list)
    input_files = [input_files, ' ', file_list{i}];
end
%input_files;

wd = pwd;
cd(data_path); %switch to data_path so tar can find the files

cmd = 'cat /etc/hostname';
[a, host_name] = system(cmd);
base_dir = fullfile(base_dir);
base_dir(find(base_dir== '/')) = '.';
t = clock();
t_string = [num2str(t(4)), num2str(t(5)), num2str(floor(t(6)))];
out_name = [base_dir, host_name(1:end-1), '.', date(),'.',t_string, '.tar.gz'];
cmd = ['tar -cvzf ', out_name, ' ', input_files];
system(cmd);
disp(['Finished! ', out_name, ' succesfully saved, under ', data_path]);

cd(wd); % return to the users working directory




