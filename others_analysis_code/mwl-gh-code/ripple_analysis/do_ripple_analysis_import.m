function cdat = do_ripple_analysis_import(chanmap,chans)

this_dir = dir;
ndir = size(this_dir,1);
is_eeg = zeros(ndir,1);
name_length = zeros(ndir,1); % list of file name lengths
for i = 1:ndir
    this_name = this_dir(i).name;
    index = find(this_name=='.');
    name_length = numel(this_name);
    if (size(index) == 1) % no double-extention files
        if strcmp(this_name(index:name_length),'.eeg')
            is_eeg(i) = 1;
            name_length(i) = index - 1;
        end
    end
end
if (sum(is_eeg) == 0)
    disp('No eeg files found in this directory');
else
    disp(['Found ', sum(is_eeg), ' eeg files']);
end
neeg = sum(is_eeg);
eeg_file_index = find(is_eeg);
comp = struct;
for i = 1:neeg
   filesize =  this_dir(eeg_file_index(i));
   if filesize < 200e6 % if gt than 200 Mb, eeg2mat will error
       chunk_count = ceil(filesize /
       comp(i).
   else % just bring in the file
       
end