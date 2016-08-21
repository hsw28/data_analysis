function extract_session(session_dir)
%EXTRACT_SESSION extract raw AD36 data files
%
%  EXTRACT_DAY(session_dir) this function will extract the raw data files 
%  in  session_dir (which should be formatted as day##). The extracted
%  files will be saved in extracted_data and the extracted event strings 
%  will be placed in extracted_dta/events/  the raw data files are moved to
%  the raw_data subdirectory.
%
%  Spikeparms2 will be run on all tt files, and the resulting .pxyabw files
%  are saved along side the .tt files under extracted_data
%  Based upon extract_day by Fabian Kloosterman, edited and changed by 
%  Stuart Layton, 2009, MIT, slayton@mit.edu
%
%  This script is usually run by process_session
%
% see also process_session 

%define regular expressions
master_pat = 'master(?<day>\d+)\.st.'; %example: master01.stu
spike_pat = 't(?<tetrode1>\d\d)t(?<tetrode2>\d\d)(?<day>\d\d)\.st.'; %example: t01t0203.stu
eeg_pat = 'eeg(?<number>\d*)_(?<day>\d+)\.st.'; %example: eeg1_01.stu or eeg2_04.stu

% Create Raw Directory and move the data there
raw_dir = fullfile(session_dir, 'raw_data');
mkdir(raw_dir);
movefile(fullfile(session_dir, '*.st*'), raw_dir);    

%Create Directory for extracted_data
extracted_dir = fullfile(session_dir, 'extracted_data');
mkdir(extracted_dir);
mkdir(fullfile(extracted_dir, 'events'));
files =  dir(fullfile(raw_dir, '*.st*'));%get all files in rootdir/raw

%step1 - extract master
  %find master file
  disp('Extracting Master File');
  r = regexp({files.name}, master_pat, 'names');
  matches = find( ~cellfun('isempty', r) );
  
  if length(matches)>1
    error('More than one master file. No extraction.')
  elseif length(matches)==1
    in_file = fullfile(raw_dir, files(matches).name);
    %extract master file events
    out_file = fullfile(extracted_dir, 'events', ['master' r{matches}.day '.es']);
    if ~exist(out_file, 'file')
      cmd = ['adextract ' ' -e -o ' out_file ' ' in_file '&'];
      system(cmd); %#ok 
    else
      error('No master file found.');
    end 
    %extract master file position data
    disp('     ----- Master File -----');
    out_file = fullfile(extracted_dir,  ['master' r{matches}.day '.pos']);
    if ~exist(out_file, 'file')
      cmd = ['adextract ' ' -p -o ' out_file ' ' in_file];
      system(cmd); %#ok
      disp('Creating temporary position file for clustering');
      cmd = ['posextract ', out_file,' -o ', fullfile(extracted_dir,'temp_pos.p')];
      system(cmd);
    else
      disp(['File ' out_file ' exists. No extraction of ' files(matches).name]);
    end
  end
%step1 complete


%step2 - extract spike files
  %find spike files
  disp('Extracting Tetrode Files');
  r = regexp({files.name}, spike_pat, 'names');
  matches = find( ~cellfun('isempty', r) );
  
  for i=matches
    disp(['     -----Tetrode:', r{i}.tetrode1, ' and Tetrode:' r{i}.tetrode2, '-----']);
    
    in_file = fullfile(raw_dir, files(i).name);
       
    %extract spike file events
    out_file = fullfile(extracted_dir, 'events', ['d' r{i}.day '_t' r{i}.tetrode1 't' r{i}.tetrode2 '.es']);
    if ~exist(out_file, 'file')
      cmd = ['adextract '  ' -e -o ' out_file ' ' in_file];
      system(cmd); %#ok 
    else
        disp(['File ' out_file ' exists. No extraction of ' files(i).name])
    end 
    
    %extract spike file probe 0
    out_file = fullfile(extracted_dir, ['d' r{i}.day '_t' r{i}.tetrode1]);
    if ~exist(out_file, 'file')
      cmd = ['adextract '  ' -t -probe 0 -o ' out_file '.tt ' in_file];
      system(cmd); %#ok       
    else
      disp(['File ' out_file ' exists. No extraction of '  files(i).name]);
    end

    %extract spike file probe 1
    out_file = fullfile(extracted_dir, ['d' r{i}.day '_t' r{i}.tetrode2]);
    if ~exist(out_file, 'file')
      cmd = ['adextract '  ' -t -probe 1 -o ' out_file '.tt ' in_file];
      system(cmd); %#ok      
    else
      disp(['File ' out_file ' exists. No extraction of ' files(i).name]);
    end
  end
%step2 complete


%step3 - extract eeg files
  disp('Extracting EEG');
  r = regexp({files.name}, eeg_pat, 'names');
  matches = find( ~cellfun('isempty', r) );
  
  for i=matches
    disp(['     -----', files(i).name, '-----']);
    in_file = fullfile(raw_dir, files(i).name);
    disp(['Extracting ' in_file '...'])    
    %extract eeg file events
    out_file = fullfile(extracted_dir, 'events', ['eeg' r{i}.number '_' r{i}.day '.es']);
    cmd = ['adextract '  ' -e -o ' out_file ' ' in_file];
    system(cmd); %#ok 
    %extract eeg file eeg data
    out_file = fullfile(extracted_dir, ['eeg' r{i}.number '_' r{i}.day '.eeg']);
    cmd = ['adextract '  ' -c -o ' out_file ' ' in_file];
    system(cmd); %#ok
  end
  
%step3 complete


%step4 - extract spike features
disp('Extracting Waveform Data from Tetrode files');  
filefun(@process_waveform, 'Path', extracted_dir, 'Mask', '*.tt' );

%step4 complete
disp('Extraction complete!!!')


  function process_waveform(rootdir, file, level) %#ok
  %PROCESS_WAVEFORM run spikeparms2 on a file
  
  [p, f, e, v] = fileparts(file); %#ok
  in_file = fullfile(rootdir, file);    
  
  disp(['     Running spikeparms2 on ' file ])
  
  out_file = fullfile(rootdir, [f '.pxyabw']);
  cmdStrStuart = ['spikeparms2 -tetrode -binary -parms t_px,t_py,t_pa,t_pb,t_maxwd,t_maxht,time,t_h1,t_h2,t_h3,t_h4 -pos ', fullfile(extracted_dir, '*.p'), ' -o '];
  %cmdStrFab = 'spikeparms2 -tetrode -binary -fset1 -o ';
  cmd = [cmdStrStuart out_file ' ' in_file];
  system(cmd); %#ok
  end
end