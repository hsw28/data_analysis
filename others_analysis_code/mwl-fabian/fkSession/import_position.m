function position = import_position( rootdir, varargin )
%IMPORT_POSITION import position data
%
%  pos=IMPORT_POSITION(rootdir) import position data for epoch in
%  rootdir.
%
%  pos=IMPORT_POSITION(rootdir,parm1,val1,...) specify optional
%  parameter/value pairs. Valid options are:
%   fstracker - tracker rate in Hz (default=30)
%   velsmooth - standard deviation in seconds of gaussian velocity
%               smoothing filter (default=0.5)
%   hdchangesmooth - standard deviation in seconds of gaussian head
%                    direction change smoothing filter (default=0.1)
%

%  Copyright 2007-2008 Fabian Kloosterman


VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

options = struct( 'fstracker', 30, 'velsmooth', 0.5, 'hdchangesmooth', 0.1 );
options = parseArgs( varargin, options );

%check options
if ~isnumeric(options.fstracker) || ~isscalar(options.fstracker) || ...
        options.fstracker<=0 || isnan(options.fstracker) || ...
        isinf(options.fstracker)
    error( 'import_position:invalidArgument', ['Invalid tracker ' ...
                        'rate']);
end

if ~isnumeric(options.velsmooth) || ~isscalar(options.velsmooth) || ...
        options.velsmooth<0 || isnan(options.velsmooth) || ...
        isinf(options.velsmooth)
    error( 'import_position:invalidArgument', ['Invalid standard ' ...
                        'deviation for gaussian velocity smoothing filter']);
end

if ~isnumeric(options.hdchangesmooth) || ~isscalar(options.hdchangesmooth) || ...
        options.hdchangesmooth<0 || isnan(options.hdchangesmooth) || ...
        isinf(options.hdchangesmooth)
    error( 'import_position:invalidArgument', ['Invalid standard ' ...
                        'deviation for gaussian hd change smoothing filter']);
end


env = import_env( rootdir );

if exist( fullfile(rootdir, 'position', 'position.p'),'file' )
  f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
  position = load(f);
  verbosemsg('Position data loaded.')
else
  position = [];
  verbosemsg('No position data.')
  return
end


fn = fieldnames(position);

for k = 1:numel(fn)   
  position.(fn{k}) = position.(fn{k})';   
end

if ~isempty(env)
  
  position.units = env.units;
  
  position.headdir = limit2pi(position.headdir + env.rotation);
  
  %transform position data
  verbosemsg('Transformation of position data')
  
  position.diode1 = env.pixelpos2world( position.diode1 );
  position.diode2 = env.pixelpos2world( position.diode2 );
  position.headpos = env.pixelpos2world( position.headpos );
  
else
  
  position.units = 'pixels';
  position.headdir = limit2pi(position.headdir); 
  
end

%calculate velocity
verbosemsg('Compute velocity...', VERBOSE_MSG_LEVEL+1)
Fs_tracker = options.fstracker;

position.velocity = gradient( position.headpos(:,1), 1./Fs_tracker ) + i.*gradient( position.headpos(:,2), 1./Fs_tracker );

verbosemsg(['Smooth velocity (sd=' num2str(options.velsmooth) 's)...'], VERBOSE_MSG_LEVEL+1)
position.velocity = smoothn( position.velocity, options.velsmooth, 1./Fs_tracker, ...
                             'correct', true, 'nanexcl', true);    

verbosemsg('Compute head direction change velocity...', VERBOSE_MSG_LEVEL+1)
position.hdchange = gradient( unwrap( position.headdir ), 1./Fs_tracker );

verbosemsg(['Smooth head direction change (sd=' num2str(options.hdchangesmooth)  's)...'], VERBOSE_MSG_LEVEL+1)
position.hdchange = smoothn( position.hdchange, options.hdchangesmooth, 1./Fs_tracker, ...
                             'correct', true, 'nanexcl', true);

