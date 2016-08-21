function eeg = import_eeg( rootdir, epoch )
%IMPORT_EEG import eeg data
%
%  eeg=IMPORT_EEG(rootdir,epoch)

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end


eeg = [];

%load signals.dat
verbosemsg('Importing sources and signals...')
[sources, signals] = import_sources_and_signals( rootdir ); %#ok

if ~isempty(signals)
    
  %find eeg signals
  idx = find( strcmp( strtrim(signals.type), 'eeg' ) & ~signals.source==0 );
    
  verbosemsg(['Found ' num2str(numel(idx)) ' eeg signals - gathering information.']);
    
  for k=1:numel(idx)
    
    eeg(k).signal = signals.id(idx(k));
    eeg(k).name = signals.name{idx(k)};
    eeg(k).source = signals.source(idx(k));
    eeg(k).source_name = sources.name{eeg(k).source};
    eeg(k).sensor_name = sources.sensor{eeg(k).source};
    eeg(k).refsource = signals.refsource(idx(k));
    eeg(k).epochpath = fullfile(rootdir, 'epochs', epoch);
    eeg(k).file = signals.file{idx(k)};
    eeg(k).channel = signals.channel(idx(k));
    [eeg(k).rate, eeg(k).gain, eeg(k).filter_low, eeg(k).filter_high] ...
        = get_file_info( fullfile(rootdir, 'epochs', epoch, 'eeg', eeg(k).file), eeg(k).channel );

    %copy variables before defining function handles
    filename = eeg(k).file;
    channel = eeg(k).channel;
    gain = eeg(k).gain;
    name = eeg(k).name;
    eeg(k).load = @(varargin) load_eeg( fullfile(rootdir, 'epochs', ...
                                                 epoch, 'eeg', filename), channel, gain, varargin{:} );
    eeg(k).props = @(varargin) load_props( fullfile(rootdir, 'epochs', ...
                                                    epoch, 'eeg'), [name '.signal'], varargin{:} );
        
    verbosemsg(['EEG ' eeg(k).name ' (signal=' num2str(eeg(k).signal) ...
                ', source=' num2str(eeg(k).source) ', file=' eeg(k).file ...
                ', channel=' num2str(eeg(k).channel) ')'],VERBOSE_MSG_LEVEL+1);
  end
  
end


function [data, time] = load_eeg( file, channel, gain, varargin )

fid = mwlopen( file );
data = load( fid, {'timestamp', ['channel' num2str(channel)]}, varargin{:} );
time = data.timestamp';
data = (10*double(data.(['channel' num2str(channel)])')./2048)./gain*1e3;

function [rate, gain, filter_low, filter_high] = get_file_info( filename, chan)

f = mwlopen( filename );
hdr = f.header;
param = getFirstParam(hdr,'Rate');
if isempty(param)
  rate = -1;
else
  rate = str2double(param);
end

s = sprintf('channel %d ampgain', chan-1);
gain = str2num( getFirstParam(hdr,s) ); %#ok
s = sprintf('channel %d filter', chan-1);
tmp = str2num( getFirstParam(hdr,s) ); %#ok
[filter_low filter_high] = ad_filter_convert(tmp);

    
