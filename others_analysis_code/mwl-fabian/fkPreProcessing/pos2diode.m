function status=pos2diode(posfilename, dest_file)
%POS2DIODE process raw position file and output diode position
%
%  status=POS2DIODE(posfile)
%

% Copyright 2008-2009 Fabian Kloosterman

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%test for valid file name
if nargin<1
    help(mfilename)
    return
elseif ~ischar(posfilename) || ~exist(posfilename,'file')
    error('pos2diode:invalidArgument', 'Invalid file name')
end

%check for explicit destination file
if nargin<2 || isempty(dest_file)
    dest_file = [posfilename '.diode'];
elseif ~ischar(dest_file)
    error('pos2diode:invalidArgument', 'Invalid destination file')
end
    

[pospath, posname, posext] = fileparts( posfilename ); %#ok

%load raw position data
verbosemsg(['Loading raw position data from ' posfilename]);
  
posfile = mwlopen( posfilename );
nrecords = get(posfile, 'nrecords');

posdata = loadrange( posfile, 'all');

status = struct( 'file', posfilename, 'nrecords', nrecords);

%make sure the first frame is zero and the last frame is 1
first_frame = posdata.frame(1)==1;
last_frame = posdata.frame(end)==0;

remove_idx = [];
  
if first_frame %starts with odd frame -> remove it
  remove_idx = 1;
end
if last_frame %ends with even frame -> remove it
  remove_idx = [remove_idx ; nrecords];
end 
  
%process gaps - synchronize diodes across gaps
verbosemsg('Synchronizing diodes across gaps in time...')


idx = find( diff( posdata.timestamp ) > 800 );
remove_idx = [remove_idx; vertcat( idx(posdata.frame(idx)==0), idx(posdata.frame(idx+1)==1)+1 )];

%plot(remove_idx)

keep_idx = setdiff( (1:nrecords)', remove_idx );

posdata = structfun( @(fld) fld(keep_idx), posdata, 'UniformOutput', false );

status.firstframeisodd = first_frame;
status.lastframeiseven = last_frame;
status.ndiodegapsync = numel(remove_idx);
status.nvalidframes = numel(posdata.frame);
   
 
%separate frames and convert to diode coordinates
verbosemsg('Calculating diode positions...')
frame0 = (posdata.frame==0);
diode0 = raw2diode( structfun( @(fld) fld(frame0), posdata, 'UniformOutput', false ) );
diode1 = raw2diode( structfun( @(fld) fld(~frame0),posdata, 'UniformOutput', false ) );
 
timestamps = double(posdata.timestamp(1:2:end)) / 10000;

ms = min([size(diode0,1), size(diode1,1)]);
diode0 = diode1(1:ms,:);
diode1 = diode1(1:ms,:);
timestamps = timestamps(1:ms,:);

[size(diode0), size(diode1)]
posdata = [diode0 diode1];
clear diode1 diode0;
  
status.raw2diode.nempty_diode0 = numel( find( isnan( posdata(:,1) ) ) );
status.raw2diode.nempty_diode1 = numel( find( isnan( posdata(:,3) ) ) );    
    
%save diode data
verbosemsg(['Saving diode position to ' dest_file])


    flds = mwlfield({'timestamp', 'diode1', 'diode2'}, {'double', 'double', 'double'}, {1 2 2});
    
    size(timestamps)
    size(posdata(:,[1 2])')
    size(posdata(:,[3 4])')
    
    f = mwlcreate(dest_file, 'feature', ...
              'Fields', flds, 'Data', {timestamps, posdata(:,[1 2])', posdata(:,[3 4])'},...
              'Mode', 'overwrite'); %#ok


