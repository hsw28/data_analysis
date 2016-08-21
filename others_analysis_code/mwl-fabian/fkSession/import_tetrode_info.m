function tetrodes = import_tetrode_info( rootdir )
%IMPORT_TETRODE_INFO import tetrode information
%
%  tetrodes=IMPORT_TETRODE_INFO(rootdir)
%

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

tetrodes = struct('id', {}, 'name', {}, 'source', {}, 'source_name', {}, ...
                  'sensor_name', {}, 'refsource', {}, 'probe', {}, ...
                  'rate', {}, 'gain', {}, 'threshold', {}, 'filter_low', {}, ...
                  'filter_high', {}, 'waveform_file', {});

%load signals.dat
verbosemsg('Importing sources and signals...')
[sources, signals] = import_sources_and_signals( rootdir ); %#ok


if ~isempty(signals)
  
  %find spike signals
  tid = find( strcmp( signals.type, 'spike' ) );
  
  verbosemsg(['Found ' num2str(numel(tid)) ' tetrodes - gathering ' ...
              'information.']);
  
  %loop through all spike signals
  for k = 1:numel(tid)
    
    %gather info
    tetrodes(k).id = str2num( signals.name{tid(k)}(2:end) ); %#ok
    tetrodes(k).name = signals.name{tid(k)};
    tetrodes(k).source = signals.source(tid(k));
    tetrodes(k).source_name = sources.name{tetrodes(k).source};
    tetrodes(k).sensor_name = sources.sensor{tetrodes(k).source};
    tetrodes(k).refsource = signals.refsource(tid(k));
    tetrodes(k).waveform_file = fullfile( 'waveforms', tetrodes(k).name, ...
                                          signals.file{tid(k)} );
                
    %retrieve information from waveform file
    [tetrodes(k).probe, tetrodes(k).rate, tetrodes(k).gain, ...
     tetrodes(k).threshold, tetrodes(k).filter_low, tetrodes(k).filter_high] ...
        = get_file_info( fullfile(rootdir, tetrodes(k).waveform_file) );
    
    waveform_file = fullfile( rootdir, 'waveforms', tetrodes(k).name, ...
                              signals.file{tid(k)} );
    
    %construct function handle for loading waveforms
    g = tetrodes(k).gain;
    tetrodes(k).waveforms = @(varargin) load_tt_waveforms(waveform_file,g,varargin{:});
        
        
    verbosemsg(['Tetrode ' num2str(tetrodes(k).id) ' (name=' tetrodes(k).name ...
                ', source=' num2str(tetrodes(k).source) ...
                ', file=' tetrodes(k).waveform_file ...
                ')'],VERBOSE_MSG_LEVEL+1);
  end
  
end


function [probe, rate, gain, threshold, filter_low, filter_high] = get_file_info( filename )
%GET_FILE_INFO

%open waveform file
f = mwlopen( filename );

hdr = f.header;

probe = str2num(getFirstParam(hdr,'Probe')); %#ok

nchan = str2num(getFirstParam(hdr,'nchannels')); %#ok
rate = str2num(getFirstParam(hdr,'rate')) ./ nchan; %#ok

for chan = 0:3
    c = chan + 4*probe;
    s = sprintf('channel %d ampgain', c);
    gain(chan+1) = str2num( getFirstParam(hdr,s) ); %#ok
    s = sprintf('channel %d threshold', c);
    threshold(chan+1) = str2num( getFirstParam(hdr,s) ); %#ok
    s = sprintf('channel %d filter', c);
    tmp = str2num( getFirstParam(hdr,s) ); %#ok
    [filter_low filter_high] = ad_filter_convert(tmp);
end
        
function [w,t] = load_tt_waveforms( wavefile, gain, range, convert, threshold, timerange )
%LOAD_TT_WAVEFORMS

if nargin<3 || isempty(range) || ~isnumeric(range)
  range = []; %load all records
end

if nargin<4 || isempty(convert) || ~isnumeric(convert)
  convert = 0;
else
  convert = ~isequal(convert,0);
end

if nargin<5 || isempty(threshold) || ~isnumeric(threshold)
  threshold = 0;
end

f = mwlopen( wavefile );

if nargin<6 || isempty( timerange ) || isequal(timerange,0)
  w = load( f, {'timestamp','waveform'}, range );
else
  range = range.*10000; %convert from seconds to timestamps
  w = loadrange(f, {'timestamp','waveform'}, range, 'timestamp');
end
  
t = double(w.timestamp)./10000;
w = w.waveform;

if convert
  w = bsxfun(@rdivide, 10.*double(w)./2048, gain(:) ) * 1e3;
end

if ~isequal(threshold,0)
  valid = max( reshape(w,128,size(w,3)) )>=threshold;
  w = w( :,:, valid );
  t = t(valid);
end