function [waveforms, ts] = import_waveforms_from_tt_file(file, varargin)

if ~exist(file,'file')
    warning('%s file does not exist', file);
    waveforms = [];
    ts =[];
    return;
end

args.idx = [];
args.time_range = [];
args.anti_idx = 0;
args = parseArgs(varargin,args);

fields = {'waveform', 'timestamp'};
  
d = dir(file);

% if the file is less than 10K in size, skip it
if d.bytes < 10000
    waveforms = [];
    ts = [];
    return;
end

mwlf = mwlopen(file);


if ~isempty(args.idx)
    f = load(mwlf, fields, args.idx);
else
    f = loadrange(mwlf, fields, args.time_range*10000, 'timestamp');
end

waveforms = double(f.waveform);

gains = get_gains(file);    
waveforms = ad2uv(waveforms, gains);

ts = double(f.timestamp)/10000;  
   
end


function gains = get_gains(file)

    head = loadheader(file);

    chans = [0 1 2 3];

    if strcmp(head(1).Probe,'1')
        chans = chans+4;
    end

    strA = 'channel ';
    strB = ' ampgain';
    gains = nan(1,4);
    for j=1:length(chans);
        str(j,:) = [strA, num2str(chans(j)), strB];
        gains(j) = str2double(head(2).(str(j,:)));
    end
end      





