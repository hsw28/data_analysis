function eeg = load_exp_eeg(edir, ep, varargin)
%LOAD_EXP_EEG loads eeg data from mwl.eeg files
%
%   eeg=LOAD_EXP_EEG(experiment_directory, epoch) loads all data from all
%   .eeg files contained in the experiment directory. Data is saved in a
%   struct with subfields that contain the actual data. The voltages are
%   saved in the .data subfield which is a 1x(MxC) cell array wich each index
%   having 1xn data points.  M is the number of eeg files and C is the number
%   of channels per file
% 
%   More arguments can be passed in a key value pair system, the following
%   valid key value pairs are:
%
%   ignore_eeg_channel
%   which has an accompanying value of a cell array containing
%   the channels to not load, channels can be specifed with the
%   following expression eegN.chK where N is the file number and K is the
%   channel number
%
%   ignore_eeg_file
%   which has the accompanying value of a cell array containing the list of
%   files to ignore. Files can be specifed with the following expression of
%   eegN  where N is the number of the eeg file in the actual file name

% args.fields = {'timestamp',...
%     'channel1', 'channel2', 'channel3', 'channel4',...
%     'channel5', 'channel6', 'channel7', 'channel8'};
% args.ignore_eeg_channel = {'none'};
% args.ignore_eeg_file = {'none'};
% 
% args = parseArgsLite(varargin, args);
% data = [];
% ts = {};
% fs = nan;
% loc = {};
% file = {};
% ch = {};
% 
% [en et] = load_epochs('', 'epoch_file', fullfile(edir, 'epochs.def'));
% et = et(ismember(en, ep),:);
% 
% eeg_files = get_dir_names(fullfile(edir, '*.eeg'));
% nc = 0;
% 
% file_n = 0;
% for i = 1:numel(eeg_files)
% 
%     file_n = file_n+1;
%     if ~strcmp( args.ignore_eeg_file, eeg_files{i}(1:end-4) )
%         fi = fullfile(edir, eeg_files{i});
%         disp(['loading eeg from file: ', fi]);
%         f = mwlopen(fi);
%         d = load(f, args.fields);
% 
%         i1 = find(d.timestamp>=et(1),1,'first');
%         i2 = find(d.timestamp<=et(2),1,'last');
% 
%         ind = i1:i2;
%         c=0;
%         for j=2:numel(args.fields)
% 
%             c = c+1;
%             if c>8
%                 c=1;
%             end
%             
%             chan_id = ['eeg', num2str(file_n), '.ch', num2str(c)];
%             if ~ismember(args.ignore_eeg_channel, chan_id)
%                 nc = nc+1;
%                
%                 data(:,nc) = d.(args.fields{j})(ind);
%                 loc{nc} = 'not specified';
%                 %file{nc} = fi
%                 ch{nc} = chan_id;
%             else
%                 disp(['Skipping Channel: ', chan_id]);
%             end
%         end
% 
%         ts = d.timestamp(ind)';
%         fs = mode(diff(ts));
%     else
%        disp(['Skipping file: ',fullfile(edir, eeg_files{i})] );
%     end
% end
% 

doneFile = fullfile(edir, [ep, '.1500hz.mat']);
tmp = load(doneFile);

ch = cell(16,1);
for i = 1:size(tmp.eeg,1)
    ch{i} = sprintf('eeg%d.ch%d', ceil(i/8), mod(i,8)+1);
end

eeg.data = double(tmp.eeg');
eeg.ts = tmp.ts';
eeg.fs =  1.0000 / mean(diff(eeg.ts));
eeg.loc = repmat({'not specified'}, size(eeg.data,1), 1);
eeg.file = doneFile;
eeg.ch = ch;

end