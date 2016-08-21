function status = process_behavior( posfile, dest_file, varargin )
%PROCESS_BEHAVIOR compute head position and direction
%
%  status=PROCESS_BEHAVIOR(posfile,destfile) for a given diode position
%  file, this function will compute the head position and direction and it
%  will let the user determine the diode orientation. The function returns
%  a structure with information about the processing.
%
%  status=PROCESS_BEHAVIOR(...,param1,val1,...) Additional parameter/value
%  pairs can be provided:
%   diodeorientation - uses this orientation without asking the user
%

%  Copyright 2009 Fabian Kloosterman


%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%check for valid file name
if nargin<1
    help(mfilename)
    return
elseif ~ischar(posfile) || ~exist(posfile,'file')
    error('process_behavior:invalidArgument', 'Invalid file name')
end

%check for explicit destination file
if nargin<2 || isempty(dest_file)
    dest_file = [posfile '.behav'];
elseif ~ischar(dest_file)
    error('process_behavior:invalidArgument', 'Invalid destination file')
end

options = struct( 'diodeorientation', [] );
options = parseArgs(varargin,options);

%load diode position data
verbosemsg( ['Loading diode positions from ' posfile]);

f = mwlopen(posfile);
posdata = load( f, 'all' ); 
posdata.timestamp = posdata.timestamp';
posdata.diode1=posdata.diode1';
posdata.diode2=posdata.diode2';

%compute head position (average of two diodes)
verbosemsg('Computing behavior...')

headpos = ( posdata.diode1 + posdata.diode2 ) / 2;
%diode direction (from diode 1 -> diode 2)
hd = atan2( -(posdata.diode1(:,2)-posdata.diode2(:,2)), posdata.diode1(:,1)-posdata.diode2(:,1) );

%determine diode orientation
if isempty(options.diodeorientation)
    
    verbosemsg('Let user determine diode orientation')
    
    dx = gradient(headpos(:,1) );
    dy = gradient(headpos(:,2) );
    mvdir = atan2( -dy, dx ); %moving direction
    speed = sqrt(dx.^2 + dy.^2); %speed
    
    %compute difference between head direction and moving direction
    delta = circ_diff( mvdir, hd, 1 );
    
    [md, th] = diode_orient_gui( delta, speed ); %#ok
    
    answer = input(['Specify diode orientation (default=' num2str(md) '): ']);
    
    if isempty(answer)
      options.diodeorientation = md;
    else
      options.diodeorientation = double(answer);
    end
    
elseif ~isnumeric(options.diodeorientation) || ~isscalar(options.diodeorientation)
    
        error('process_behavior:invalidArgument', 'Invalid diode orientation')
end
    
hd = limit2pi( hd - options.diodeorientation, -pi );
    
status.diodeorientation = limit2pi(options.diodeorientation,-pi);

%save positional data
verbosemsg(['Saving behavior data to ' dest_file]);

flds = mwlfield({'timestamp', 'headpos', 'headdir'}, {'double', 'double', 'double'}, {1 2 1});
f = mwlcreate(dest_file, 'feature', 'Fields', flds, ...
    'Data', {posdata.timestamp, headpos', hd'}, ...
    'Mode', 'overwrite', ...
    'Header', header('Diode Orientation', options.diodeorientation)); %#ok
