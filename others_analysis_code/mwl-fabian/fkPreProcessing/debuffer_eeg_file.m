function status = debuffer_eeg_file( eegfile, dest_file, varargin )
%DEBUFFER_EEG_FILE unbuffer and resample .eeg files
%
%  DEBUFFER_EEG_FILE(eegfile)
%
%  DEBUFFER_EEG_FILE(eegfile,destfile)
%
%  DEBUFFER_EEG_FILE(...,parm1,val1,...) Specify additional parameter/value
%  pairs:
%    epoch - 2 element vector specifying the start and end times of the
%            epoch to process
%    fs - new sampling rate of unbuffered eeg (default = min(600,current
%         rate))
%
%  status=DEBUFFER_EEG_FILE(...) returns structure with information
%

% Copyright 2009 Fabian Kloosterman

%test for valid file name
if nargin<1
    help(mfilename)
    return
elseif ~ischar(eegfile) || ~exist(eegfile,'file')
    error('debuffer_eeg_file:invalidArgument', 'Invalid file name')
end

%check for explicit destination file
if nargin<2 || isempty(dest_file)
    dest_file = [eegfile '.debuf'];
elseif ~ischar(dest_file)
    error('debuffer_eeg_file:invalidArgument', 'Invalid destination file')
end

%process optional keyword arguments
options = struct('epoch', [], 'fs', [] );
options = parseArgs( varargin,options);

%open eeg file
f = mwlopen( eegfile );

if ~strcmp( getFileType(f), 'eeg' )
    error('debuffer_eeg_file:invalidFile', [eegfile ' is not a valid mwl .eeg file'])
end
   
%get file information
flds = get(f, 'fields');
fielddef = mex_fielddef( flds );
nrecords = get(f, 'nrecords');
nsamples = get(f, 'nsamples');
  
%find sampling rate and number of channels in header of file
h = get(f, 'header');
rate = str2num(getFirstParam(h,'rate')); %#ok
nchan = str2num(getFirstParam(h,'nchannels')); %#ok
samp_freq_orig = rate / nchan;

%check new sampling rate
if isempty(options.fs)
    Fs_new = min( rate, 1500 );
elseif ~isnumeric(options.fs) || ~isscalar(options.fs) || options.fs<=0 || options.fs>rate
    error('debuffer_eeg_file:invalidRate', 'Invalid new sampling rate')
else
    Fs_new = options.fs;
end

%check epoch
epoch = double(f([0 nrecords-1]).timestamp)./10000 + [0 (nsamples-1)./samp_freq_orig];

if isempty(options.epoch)
    %pass
elseif ~isnumeric(options.epoch) || ~isequal(size(options.epoch), [1 2]) || diff(options.epoch)<=0
    error('debuffer_eeg_file:invalidEpoch', 'Invalid epoch')
else
    epoch = options.epoch;
end

%define resample filter
resample_filter = @(Fs_old, Fs_new) fir1( 30*ceil(Fs_old/Fs_new), Fs_new./Fs_old );

status = struct('eeg_file', eegfile, 'destination', dest_file, 'epoch', epoch, ...
    'original_sampling_rate', samp_freq_orig, 'new_sampling_rate', Fs_new, ...
    'resample_filter', func2str(resample_filter) );

%create new timestamp vector
T = (epoch(1,1):(1/Fs_new):epoch(1,2))';
%create new data matrix
D = zeros(numel(T),nchan, 'int16');
    
%get buffers with timestamps closest to requested epoch range
idx = findrecord(fullfile(f), epoch(1,:) * 10000, fielddef(1,:), get(f, 'headersize'), get(f, 'recordsize'));
    
if (idx(1)==-1)
  error('debuffer_eeg_file:invalidEpoch', 'No overlap between epoch and timestamps in file')
end
    
%get timestamps of these buffers
t = double(f(idx).timestamp) / 10000;
   
%check timestamps and include adjacent buffers if necessary
if epoch(1,1)<t(1) && idx(1)>0
  idx(1) = idx(1)-1;
end
if epoch(1,2)>t(2) && idx(2)<nrecords-1
  idx(2) = idx(2)+1;
end
    
%create new header for destination file
%create fields description first
fld_names = {'timestamp'};
fld_types = {'double'};
for c = 1:nchan
  fld_names{c+1} = ['channel' num2str(c)];
  fld_types{c+1} = 'short';
end
flds = mwlfield( fld_names, fld_types, 1);

%create header and prepend it to the old header
new_h = header('Program', mfilename, ...
               'Date', [datestr(now, 'ddd ') datestr(now, 'mmm dd HH:MM:SS yyyy')], ...
               'Original rate', samp_freq_orig, 'Rate', Fs_new);
new_h = new_h + h;
    
%create new file
nf = mwlcreate(dest_file, 'feature', 'Fields', flds, 'Header', new_h, 'Mode', 'overwrite');
nf = closeHeader(nf);
    
%calculate number of buffers to process
nbuffers = diff(idx)+1;

%compute number of complete loops to make
nloadbuffer = 5000; %number of buffers to load each time
nloops = fix(nbuffers / nloadbuffer);
    
gaps = [];

status.buffers = idx;

%process the data block-wise to prevent memory overflow
for l = 1:(nloops+1)
      
  %correctly deal with edge cases
  if l==(nloops+1) %last loop
    if nloops == nbuffers / nloadbuffer
      break
    end
    load_idx = repmat( idx(1) + (l-1)*nloadbuffer, 1, 2);
    load_idx(2) = load_idx(2) + mod( nbuffers-1, nloadbuffer );
    buffers_loaded = mod( nbuffers-1, nloadbuffer ) + 1;
  else
    load_idx = idx(1) + [((l-1)*nloadbuffer) (l*nloadbuffer-1)];            
    buffers_loaded = nloadbuffer;
  end
     
  %include extra buffers to reduce edge effects of filtering
  if load_idx(1)>0
    load_idx(1) = load_idx(1)-1;
    start_ext = 1;
  else
    start_ext = 0;
  end
  if (load_idx(2)<nrecords-1)
    load_idx(2) = load_idx(2)+1;
    end_ext = 1;
  else
    end_ext = 0;
  end
  
  %load buffers
  data = f(load_idx(1):load_idx(2));
  
  %convert and extrapolate timestamps
  data.timestamp = double(data.timestamp) / 10000;
  data.timestamp = repmat( data.timestamp(:)', nsamples, 1);
  data.timestamp = data.timestamp(:) + repmat( (0:nsamples-1)' , buffers_loaded + start_ext + end_ext, 1) / samp_freq_orig;
            
  %check for gaps     
  gaps = [gaps ; load_idx(1) + find( diff(data.timestamp) > 1.5*(nsamples*nchan/rate) )]; %#ok
      
  %filter eeg data
  %length of filter is at least 30 cycles of highest remaining
  %frequency at original sampling frequency
  b = resample_filter( samp_freq_orig, Fs_new );
  tmp_data = filtfilt( b, 1, double( reshape(data.data, nchan, nsamples*(buffers_loaded + start_ext + end_ext))' ) );
      
  %find indices
  Tidx = find( T>=data.timestamp(nsamples*start_ext+1) & T<=data.timestamp(end));
  %interpolate data
  D(Tidx,:) = int16( interp1( data.timestamp, tmp_data, T(Tidx), 'linear' ) );
      
end

%save the new data
nf = appendData(nf, cat(2,{T},mat2cell( D, size(D,1), ones(1,nchan)))); %#ok
    
ngaps = numel(gaps);

status.ngaps = ngaps;
status.gaps = gaps;
