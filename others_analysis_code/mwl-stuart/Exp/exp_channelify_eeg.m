function exp_chanellify_eeg(edir, ep, varargin)
[enames etimes] = load_epochs(edir);

args.fs = 2000;
args = parseArgs(varargin, args);


epIdx = strcmp(ep, enames);
epochTimes = etimes(epIdx,:);


curDir = pwd;
cd(edir);
cd('raw');

files = dir('eeg*stu');
eeg_files = {files.name};

fs = args.fs;
if ~exist('../eeg', 'dir')
        mkdir('../eeg')
end
    
for i = 1:numel(eeg_files)
   
    % Extract files from AD files
    out_file = ['eeg', num2str(i), '.buf'];
    cmd = ['adextract -eslen80 ', eeg_files{i}, ' -c -o ', out_file];
    if ~exist(out_file, 'file')
        disp(strcat('Executing Command: ', cmd));
 %       system(cmd);     
    end
    in_file = fullfile(edir, out_file);
    
    % create two eeg files for the epoch, a full sample rate file and a
    % downsampled file
    

    out_file = ['eeg', num2str(i), '_',ep,'_', num2str(fs), 'Hz.dat'];
    out_file = fullfile(edir, out_file);
    disp(strcat('Writing file:', out_file));
    if ~exist(out_file, 'file')
        disp(strcat('Writing file:', out_file));
		disp(in_file)
        debuffer_eeg_file(in_file, out_file, 'epoch', epochTimes, 'fs', fs);
    end

    %open the newly created files and save save them as mat files
    fd = mwlopen(out_file);
    data = load(fd);
    h = get(fd,'header');
    gains = zeros(1,8);
    clear waves;
    labels = {};
    for k = 1:8
        channel = ['channel', num2str(k)];
        gain_str = ['channel ', num2str(k-1), ' ampgain'];
        gain(k) = str2double( h(3).(gain_str) );
        chStr = ['eeg', num2str(i), '.ch', num2str(k)];           
        
        waves(:,k) = data.(channel);
        Fs = 1 / mode(diff(data.timestamp));
        labels{k} = chStr;
    end
    waves = ad2mv(waves, gains);

    %load existing anatomy information if it exists
    hemi = {};
    areas = {};
    if exist('../eeg_anatomy.mat', 'file')
        anat = load('../eeg_anatomy.mat');
        anat = anat.eeg_anatomy;
        for k = 1:numel(labels)
            lab = labels{k};
            idx = find(strcmp(anat(:,1), lab), 1, 'first');
            h = anat{idx,2};
            if (h(1)=='r')
                hemi{k} = 'right';
            else
                hemi{k} = 'left';
            end
            areas{k} = h(2:end);
        end
    end

    % Save individual channels of data
    timestamps = data.timestamp;
    for j=1:size(waves,2)
        data = double(waves(:,j));
		if isempty(hemi)
			hemisphere = 'right';
			label = '';
			area = '';
		else
        	hemisphere = hemi{j};
    	    area = areas{j};
	        label = labels{j};
		end
        outfile = fullfile(edir,  [ep, '.', num2str(fs), 'Hz.mat']);
        disp(['Saving: ', outfile,'!']);
        save(outfile, 'data', 'timestamps','fs', 'area', 'hemisphere', 'label');
    end
            
end
    

cd(curDir);
    
    
% 
% eeg_files = dir('eeg*all.buf');
% eeg_files = {eeg_files.name};
% 
% for i=1:numel(eeg_files)
%     fd = mwlopen(eeg_files{i});
%     nChans = fd.nchannels;
%     data = load(fd, 'timestamp');
%     ts = data.timestamp;
%     idx = ( find(epochTimes(1)<ts, 1, 'last') : find(epochTimes(2)>ts<1, 1,'first') ) - 1;
%     data = load('fd', {'data', 'timestamp'})
% end
%         
