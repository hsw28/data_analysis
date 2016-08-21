function signals=discover_signals(rootdir,oldsignals)
%DISCOVER_SIGNALS find tetrode and eeg signals
%
%  signals=DISCOVER_SIGNALS(rootdir) find tetrode and eeg signals in
%  rootdir and returns a signal information structure.
%
%  signals=DISCOVER_SIGNALS(rootdir,signals) update signals structure
%

%  Copyright 2009 Fabian Kloosterman

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

day = str2num( rootdir(end-1:end) ); %#ok

signals = struct('id', [], 'name', [], 'source', [], 'type', [], 'refsource', [], 'file', [], 'channel', []);

if nargin<2 || isempty(oldsignals)
    oldsignals=[];
elseif ~isstruct(oldsignals) || ~all( ismember( fields(oldsignals), {'id','name','source','type','refsource','file','channel'} ) )
    error('discover_signals:invalidArgument', 'Invalid signals structure')
end
    
%find all tetrodes
filelist = dir( fullfile(rootdir, 'waveforms') );
re = 'T(?<tetrode>\d+)';
nsignals = 0;

for f=1:length(filelist)
    if filelist(f).isdir
        r = regexp(filelist(f).name, re, 'names');
        if isempty(r)
            continue
        end
        nsignals = nsignals + 1;
        signals.id(nsignals) = nsignals;
        signals.name{nsignals} = ['T' r.tetrode];
        signals.type{nsignals} = 'spike';
        signals.file{nsignals} = ['D' sprintf('%.2d', day) '_' filelist(f).name '.tt'];
        signals.source(nsignals) = 0;
        signals.refsource(nsignals) = 0;
        signals.channel(nsignals) = 0;
        
        if ~isempty(oldsignals)
            %find signal in oldsignal        
            idx = find( strcmp( oldsignals.name, signals.name{nsignals} ) & strcmp( oldsignals.type, 'spike' ) );
            if ~isempty(idx)
                %copy parameters
                signals.source(nsignals) = oldsignals.source(idx(1));
                signals.refsource(nsignals) = oldsignals.refsource(idx(1));
                signals.channel(nsignals) = oldsignals.channel(idx(1));
            end
        end

        verbosemsg(['Found tetrode: ' signals.file{nsignals}])

    end
end
  
%find all eeg files
filelist = dir( fullfile(rootdir, 'eeg', '*.eeg') );

for f = 1:length(filelist)
    filename = fullfile(rootdir, 'eeg', filelist(f).name);
    fid = mwlopen( filename );
    nchan = get(fid, 'nchannels');
    for c=1:nchan
        nsignals = nsignals + 1;
        signals.id(nsignals) = nsignals;
        signals.type{nsignals} = 'eeg';
        signals.source(nsignals) = 0;
        signals.refsource(nsignals) = 0;
        signals.name{nsignals} = [filelist(f).name '.' num2str(c)]; %['eeg' num2str(f) '_' num2str(c)];
        signals.file{nsignals} = filelist(f).name;
        signals.channel(nsignals) = c;
        
        if ~isempty(oldsignals)
            %find signal in oldsignal        
            idx = find( strcmp( oldsignals.name, signals.name{nsignals} ) & strcmp( oldsignals.type, 'eeg' ) ) & oldsignals.channel==c ;
            if ~isempty(idx)
                %copy parameters
                signals.source(nsignals) = oldsignals.source(idx(1));
                signals.refsource(nsignals) = oldsignals.refsource(idx(1));
            end
        end        
        
    end

    verbosemsg(['Found eeg file: ' signals.file{nsignals} ' (' num2str(nchan) ' channels)']);

end

