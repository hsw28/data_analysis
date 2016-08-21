function grab_epochs_xclust(session_dir)
% opens the first .pxyabw file over 10K under session_dir/extracted_data/
% this is intended to be used to grab the times from epochs from the
% position viewer included in xclust3
%
% This function could be rendered obsolete in future iterations of the
% preprocessing pipeline

%session_dir = '/home/slayton/data/spl04/day08';
pxy = dir(fullfile(session_dir, 'extracted_data', '*.pxyabw'));
bytes = 0;
i = 0;
while(bytes<10000)
    i = i+1;
    bytes = pxy(i).bytes
end

pxy = fullfile(session_dir, 'extracted_data', pxy(i).name)

cmd = ['xclust3 ' pxy];
system(cmd);
