function status = correct_position( posfile, dest_file, varargin )
%CORRECT_POSITION check and correct diode position
%
%  status=CORRECT_POSITION(posfile,destfile) Given a diode position file
%  this function will correct time gaps, interpolate small gaps in the
%  position record and filter out any outliers. The results are saved to
%  the destination file. The function returns a structure with information
%  about the corrections made.
%
%  status=CORRECT_POSITION(...,param1,val1,...) Additional parameter/value
%  pairs can be provided:
%   epoch - time epoch for which position should be corrected and saved
%   fs - sampling frequency of diode position
%   timegap - minimum interval in seconds that is considered a time gap
%

% Copyright 2009 Fabian Kloosterman

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%check for valid file name
if nargin<1
    help(mfilename)
    return
elseif ~ischar(posfile) || ~exist(posfile,'file')
    error('correct_position:invalidArgument', 'Invalid file name')
end

%check for explicit destination file
if nargin<2 || isempty(dest_file)
    dest_file = [posfile '.correct'];
elseif ~ischar(dest_file)
    error('correct_position:invalidArgument', 'Invalid destination file')
end

%process options
options = struct('epoch', [], 'fs', 30, 'timegap', 3/30);
options = parseArgs( varargin, options );

%load diode position data

verbosemsg(['Loading diode positions from ' posfile])

f = mwlopen(posfile);
if isempty(options.epoch)
    posdata = load( f, 'all' ); 
elseif ~isnumeric(options.epoch) || ~isequal(size(options.epoch),[1 2]) || diff(options.epoch)<=0
    error('corrrect_position:invalidArgument', 'Invalid epoch');
else
    posdata = loadrange( f, 'all', options.epoch, 'timestamp');
end

timestamps = posdata.timestamp';
posdata = [posdata.diode1' posdata.diode2'];

%Detect gaps in timestamps

verbosemsg('Detecting time gaps...')

dt = diff(timestamps);
dt_idx = find( dt>options.timegap );

ngaps = numel( dt_idx );

status = struct('file', posfile, 'destination', dest_file, 'epoch', options.epoch, 'fs', options.fs, ...
    'timegap', options.timegap, 'ngaps', ngaps, 'largestgap', max(dt), 'smallestgap', min(dt) );

if ngaps>0
    
    verbosemsg( [num2str(ngaps) ' gap' plural(ngaps) ' detected, resampling data']);
    
    %insert NaN for every gap
    posdata = interlace( posdata, NaN(1,4), dt_idx );
    timestamps = interlace( timestamps, num2cell( (timestamps(dt_idx) + timestamps(dt_idx+1))./2 ), dt_idx );
    
    %resample/interpolate data
    warning('off', 'MATLAB:interp1:NaNinY');
    posdata = interp1( timestamps, posdata, timestamps(1):(1/options.fs):timestamps(end) , 'linear');
    warning('on','MATLAB:interp1:NaNinY')      
    timestamps = timestamps(1):(1/options.fs):timestamps(end);
    
    status.resampled = true;
    
else
    
    status.resampled = false;
    
end

%remove jumps
verbosemsg('Removing jumps from diode position data...');
[posdata, status.filter.jumps] = filtpos_jumps( posdata );

%linearly interpolate small gaps
verbosemsg('Interpolating small gaps...')
[posdata, status.filter.smallgaps] = filtpos_gapinterp(posdata, 3);

%check diode distance
verbosemsg('Checking diode distance...')
[posdata(2:end-1,:), status.filter.diodedistance] = filtpos_checkdiodedist( posdata(2:end-1,:) );

%head direction interpolation
verbosemsg('Interpolating head direction...')
[posdata, status.filter.hdinterp] = filtpos_hdinterp( posdata );

%interpolate larger gaps
verbosemsg('Interpolating larger gaps...')
[posdata, status.filter.largegaps] = filtpos_gapinterp(posdata, 10);


%if pos data starts or ends with NaNs in either diode, remove these
first_valid = find( ~isnan( sum( posdata, 2) ), 1 );
last_valid = find( ~isnan( sum( posdata, 2) ), 1, 'last');
if first_valid~=1 || last_valid~=size(posdata,1)

    verbosemsg( 'Removing NaNs from start and end...');
    
    posdata = posdata(first_valid:last_valid, :);
    timestamps = timestamps(first_valid:last_valid);
      
end

%save corrected position

verbosemsg(['Saving corrected diode position data to ' dest_file]);

flds = mwlfield({'timestamp', 'diode1', 'diode2'}, {'double', 'double', 'double'}, {1 2 2});
f = mwlcreate(dest_file, 'feature', 'Fields', flds, ...
    'Data', {timestamps(:), posdata(:,[1 2])', posdata(:,[3 4])'}, ...
    'Mode', 'overwrite' ); %#ok

