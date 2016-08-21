function env = process_env(rootdir)
%PROCESS_ENV process environment
%
%  PROCESS_ENV(rootdir) lets the user specify the transformations between
%  the video image, the position data and the world coordinate
%  system. The procedure is as follows: both position and video image are
%  vertically flipped to make (0,0) the bottom-left corner. The user will
%  then register the video image to the position data, define the outline
%  and regions/segments that make up the environment and define the
%  trajectories. Finally the world transformation can be specified.
%  

%  Copyright 2007-2008 fabian Kloosterman


%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

env = struct( [] );
env_pixel_size = [328 254];

    function local_process()

        %create environment directory
        if ~exist( fullfile(rootdir, 'environment' ), 'dir' )
            verbosemsg('Creating environment directory...')
            [ret, msg, msgid] = mkdir(rootdir, 'environment');%#ok
        end
  
        %load prior environment definition
        filename = fullfile(rootdir, 'environment', 'environment.mat');
        if exist( filename, 'file' )
            verbosemsg(['Loading previous environment definition from ' filename])    
            env = load( filename );
            LOG.modify = true;
        end
%         filename = fullfile(rootdir, 'environment', 'environment.def');
%         if exist( filename, 'file' )
%             verbosemsg(['Loading previous environment definition from ' filename])            
%             env = config2struct( configobj( filename ) );
%             LOG.modify = true;
%         end  

        %load behavior
        if exist( fullfile(rootdir, 'position', 'behavior.p'), 'file' )
            verbosemsg('Loading behavior from behavior.p')
            f = mwlopen( fullfile(rootdir, 'position', 'behavior.p') );
            data = load(f);
            verbosemsg('Loading diode positions from position.p')            
            f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
            tmp = load( f, {'diode1', 'diode2'} );
            data.diode1 = tmp.diode1;
            data.diode2 = tmp.diode2;
        elseif exist( fullfile(rootdir, 'position', 'position.p'), 'file' )
            verbosemsg('Loading behavior and diode positions from position.p')    
            f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
            data = load(f);
        else
            error('fkEnvironment:process_env:noData', 'No position data')
        end
        
        %load video image if available
        video = import_video( rootdir );
        LOG.video = false;
        if isempty( video.video.still )
            verbosemsg('Video image NOT present...')
            img = [];
        else
            verbosemsg('Video image present...')
            img = video.video.still;
            if size(img,3)>1
                img = rgb2gray(img);
            end
            LOG.video = true; 
        end
        
        verbosemsg('Vertical flip transformation of position...')  
        %transform for flipping position in y-direction (Tposflip)
        Tposflip = T2D_scale([1 -1]);
        Tposflip = T2D_translate([0 env_pixel_size(2)+1], Tposflip)';
  
        %transform position
        pos = T2D_transform( data.headpos', Tposflip' );
        
        %register image with position data (Timg)
        if ~isempty( img )

            verbosemsg('Registering video image with position data...')
            
            %transform for flipping image in y-direction (Timgflip)
            Timgflip = T2D_scale([1 -1]);
            Timgflip = T2D_translate([0 size(img,1)+1], Timgflip)';
    
            %transform image
            img = imtransform( img, maketform( 'affine', Timgflip ) );
    
            answer = input(['Please select video image registration method:\n1. ' ...
                            'manual\n2. control points\n3. none\nEnter choice [default=manual]: '], 's');
    
            switch answer
                case {'2', 'control points', 'control', 'c'}
                    %create occupancy map of position data
                    mm = map( pos, 'Grid', { 0:1:328, 0:1:254 } );
                    %let user create control points
                    cpselect( img, uint8(255.*mm'./max(mm(:))), env.video.registration.controlpoints.input_points, env.video.registration.controlpoints.base_points);
                    input('Press enter when done');
                    %retrieve control points from base workspace
                    input_points = evalin( 'base', 'input_points' );
                    base_points = evalin( 'base', 'base_points' );
                    env.video.registration.controlpoints.input_points = input_points;
                    env.video.registration.controlpoints.base_points = base_points;
                    %do the transformation
                    t=cp2tform( input_points, base_points, 'linear conformal' );
                    Timg = t.tdata.T;
                    
                    LOG.regstration.method = 'control points';
                    LOG.registration.input_points = input_points;
                    LOG.registration.base_points = base_points;
                    
                case {'3', 'none', 'no'}
                    Timg = T2D_identity();
                    
                    LOG.registration.method = 'none';
                    
                otherwise
                    %let user register image manually by scaling, rotation
                    %and translation
                    [env.video.registration.manual, Timg] = registerimage( img, pos, ...
                        'Scale', env.video.registration.manual.scale,...
                        'Translate', env.video.registration.manual.translation,...
                        'Rotate', env.video.registration.manual.rotation);
                    
                    LOG.registration.method = 'manual';
                    LOG.registration.rotation = env.video.registration.manual.rotation;
                    LOG.registration.scale = env.video.registration.manual.scale;
                    LOG.registration.translation = env.video.registration.manual.translation;
                    
            end
  
            %transform the image
            [img, xdata, ydata] = imtransform( img, maketform('affine', Timg) );
            
        else
    
            Timgflip = T2D_identity();
            Timg = T2D_identity();
            img = [];
            xdata = NaN(1,2);
            ydata = xdata;
    
        end

        %ask for general information
        tmp = input(['Environment description [default=' env.info.description ']: '], 's');
        if ~isempty(tmp), env.info.description = tmp; end
        
        LOG.description = env.info.description;
        
        %ask for environment type
        %should be one of: 'simple track', 'complex track' (i.e. with
        %choice points), 'circular track', 'circular field', 'rectangular
        %field', 'other'
        env_types = {'simple track', 'complex track', 'circular track', 'rectangular track', 'closed track', 'circular field', 'rectangular field', 'custom field', 'other'};
        fprintf('Please select the environment type [1-6]:\n')
        fprintf('1 - simple track\n')
        fprintf('2 - complex track (with choice points)\n')
        fprintf('3 - circular track\n')
        fprintf('4 - rectangular track\n')
        fprintf('5 - closed track\n')
        fprintf('6 - circular field\n')
        fprintf('7 - rectangular field\n')
        fprintf('8 - custom field\n')
        %fprintf('9 - other\n')
        while 1
            tmp = input(['Environment type [default=' env.definition.type ']: '], 's');
            if ~isempty(tmp)
                tmp = str2double( tmp );
                if isnan(tmp) || tmp<1 || tmp>8
                    continue
                end
                if ~strcmp( env.definition.type, env_types{round(tmp)} )
                    env.definition = create_env_struct( env_types{round(tmp)}, pos);
                end
                break;
            end
        end
            
        
        %let user define tracks and stuff
        verbosemsg('Defining environment...')
        env.definition = define_env( env.definition, 'image', img, 'imagesize', [xdata;ydata], 'position', pos );
        
        if any( strcmp( env.definition.type, {'simple track', 'complex track'} ) )
            %search for connections (i.e. open polylines that connects two regions)
            env.definition.connections = struct('nodes', {}, 'edge_index', {});
            env.definition.trajectories = struct('nodes', {});

            for k=1:numel(env.definition.edges)
            
                %skip closed or single node polylines
                if env.definition.edges(k).isclosed || size(env.definition.edges(k).vertices,1)<2
                    continue
                end
            
                startregion = {};
                endregion = {};
        
                for l=1:numel({env.definition.nodes.name})

                    coords = bsxfun( @times, env.definition.nodes(l).size, [-0.5 -0.5; 0.5 -0.5; 0.5 0.5; -0.5 0.5] );
                    coords = coords * [cos(env.definition.nodes(l).rotation) -sin(env.definition.nodes(l).rotation); sin(env.definition.nodes(l).rotation) cos(env.definition.nodes(l).rotation)]';
                    coords = bsxfun( @plus, env.definition.nodes(l).center, coords );
                    
                    %find regions that contain start of polyline
                    if inpolygon( env.definition.edges(k).vertices(1,1), ...
                            env.definition.edges(k).vertices(1,2), ...
                            coords(:,1), coords(:,2) )
                    
                        startregion{end+1} = env.definition.nodes(l).name; %#ok
                
                    end
                
                    %find regions that contain start of polyline
                    if inpolygon( env.definition.edges(k).vertices(end,1), ...
                            env.definition.edges(k).vertices(end,2), ...
                            coords(:,1), coords(:,2) )
                    
                        endregion{end+1} = env.definition.nodes(l).name; %#ok
                    
                    end

                end
    
                %polylines cannot start/end in multiple regions
                %and polylines cannot start and end in the same region
                if length(startregion)==1 && length(endregion)==1 && ~strcmp(startregion{1},endregion{1})
      
                    env.definition.connections(end+1) = struct('nodes', { horzcat(  startregion, endregion) }, 'edge_index', k );
    
                end

            end

            %make sure the user did not define duplicate connections
            %and ask user for trajectories (i.e. series of connections)
            if numel(env.definition.connections)>0
            
                %ugly sorting (matlab sort doesn't do sorting of cell arrays along
                %specific dimension (R14 SP1) )
                %and ugly unique (matlab unique doesn't support 'rows' parameters for
                %cell arrays (R14 SP1) )
                tmp = {};
                for k=1:numel(env.definition.connections)
                    tmp2 = sort(env.definition.connections(k).nodes);
                    tmp{k} = horzcat( tmp2{:} ); %#ok
                end
                if numel(tmp)~=numel(unique(tmp))
                    error('process_env:invalidConnections', 'Duplicate connections')
                end
  
                %ask for trajectories
                connected_regions = vertcat(env.definition.connections.nodes);
                connected_regions = unique( connected_regions(:) );

                fprintf('Defined connected regions:\n')
  
                for i=1:numel(connected_regions)
                    fprintf([num2str(i) '. ' connected_regions{i} '\n'])
                end

                fprintf('\nPlease specify trajectories (e.g. [2 3 1] <enter>)\n')
    
                trajectories = struct( 'nodes', {} );
                done = false;
            
                while ~done

                    answer = input('Trajectory: ');
                
                    if isempty(answer)
                        done = true;
                        continue;
                    end

                    if ~isnumeric(answer) || any( answer<1 | answer>numel(connected_regions) )
                        fprintf('Invalid trajectory!\n');
                    else
                        trajectories(end+1).nodes = connected_regions(answer);
                    end

                end

                env.definition.trajectories = trajectories(:)';
        
            end

        end
        
        verbosemsg('World transformation...')
        %let user specify rotation of environment
        answer = input(['Rotation of environment in radians [default=' num2str(env.info.rotation)  ']: ']);
        if ~isempty(answer)
            env.info.rotation = double( answer );
        end

        LOG.world.rotation = env.info.rotation;

        
        %let user specify scale factor (assume pixels are square)
        answer = input(['The current scaling factor is: ' num2str(env.info.scale) ' ' env.info.units '/pixel\nChoose method to determine scaling of environent: \n1. leave as is\n2. ' ...
            'enter factor manually\n3. enter diode distance\nEnter choice [default=leave as is]: '], ...
            's');

        switch answer
            case {'2', 'manual'}
                tmp = input(['Scale factor [default=' num2str(env.info.scale) ']: ']);
                if isempty(tmp)
                    %pass
                elseif ~isnumeric(env.info.scale) || ~isscalar(env.info.scale) || env.info.scale<=0
                  error('process_env:invalidScale', 'Invalid scaling factor')
                else
                    env.info.scale = tmp;
                end
                
                tmp = input(['Environment units after scaling [default=' env.info.units ']: '], 's');
                if ~isempty(tmp), env.info.units = tmp; end
                
                LOG.world.scalemethod = 'manual';
                
             case {'3', 'diode'}
                tmp = input(['Diode distance [default=' num2str(env.info.diode_distance) ']: ']);
                if isempty(tmp)
                    %pass
                elseif ~isnumeric(env.info.diode_distance) || ~isscalar(env.info.diode_distance) || env.info.diode_distance<=0
                  error('process_env:invalidDistance', 'Invalid diode distance')
                else
                    env.info.diode_distance = tmp;
                end
    
                %compute 90th percentile of diode distance
                dd = sqrt( sum( (data.diode2 - data.diode1).^2 ) );
                m = prctile( dd(~isnan(dd)), 90 );
                
                %m = nanmedian( sqrt( sum( (data.diode2 - data.diode1).^2 ) ) );
    
                %compute scale factor as: user specified diode distance ./
                %90th percentile
                env.info.scale = env.info.diode_distance ./ m;
                  
                tmp = input(['Environment units after scaling [default=' env.info.units ']: '], 's');                                
                if ~isempty(tmp), env.info.units = tmp; end
                
                LOG.world.scalemethod = 'diode';
                
            otherwise

                %env.scale = 1;
                %env.units = '';

                LOG.world.scalemethod = 'none';
                
        end

        if isempty( env.info.units )
          env.info.units = 'pixels';
        end
           
        LOG.world.scale = env.info.scale;
        LOG.world.units = env.info.units;
        
        
        %create world transformation matrix
        Tworld = T2D_rotate( env.info.rotation );
        Tworld = T2D_scale( env.info.scale, Tworld )';

        %save transformation matrices
        env.transforms.Timgflip = Timgflip;
        env.transforms.Timg = Timg;
        env.transforms.Tposflip = Tposflip;
        env.transforms.Tworld = Tworld;
       
        
        %save environment definition to file
        verbosemsg('Saving environment definition...')
        
        save(fullfile(rootdir, 'environment', 'environment.mat'),'-struct','env');
        %c = configobj( env );
        %write(c, fullfile(rootdir, 'environment', 'environment.def') );
  
    end
        
%--LOCAL FUNCTION FOR ARGUMENT CHECKING---

    function local_check_args()

        %check root directory
        if ~exist('rootdir', 'var')
          rootdir = pwd;
        elseif ~ischar(rootdir) || ~exist(rootdir,'dir')
            error('process_env:invalidArgument', 'Invalid root directory')
        else
            rootdir = fullpath( rootdir );
        end

        LOG_ARGS = {'rootdir', rootdir};
        LOG_DESCRIPTION = 'define environment';

        %setting up default environment
        env = struct( 'info', struct( 'description', '', 'env_size', env_pixel_size, ...
              'scale', 1, 'rotation', 0, 'diode_distance', NaN, 'units', 'pixels') );

        env.transforms = struct( 'Timgflip', T2D_identity(), ...
                                 'Timg', T2D_identity, ...
                                 'Tposflip', T2D_identity, ...
                                 'Tworld', T2D_identity);

        env.video.registration = struct('manual', struct('rotation', 0, 'scale', [1 1], 'translation', [0 0]), ...
                                'controlpoints', struct('input_points',zeros(0,2), 'base_points', zeros(0,2)) );

        env.definition = struct( 'type', 'unknown' );
        %create_env_struct( 'unknown' );                          
      
        
    end

%---END OF LOCAL FUNCTIONS---

%-------------------------------------------------------------------

%---START OF DIAGNOSTICS/VERBOSE/ARGUMENT CHECKING LOGIC---

local_check_args();

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%---M-FILE DEVELOPMENT STATUS---
MODIFICATION_DATE = '$Date: 2009-10-06 20:20:18 -0400 (Tue, 06 Oct 2009) $';
REVISION = '$Revision: 2254 $';
MFILE_DEV_STATUS = regexp( [MODIFICATION_DATE REVISION], ['\$Date: (?<modification_date>.*) \$\$Revision: (?<revision>[0-9]+) \$'], 'names'); %#ok
%---M-FILE DEVELOPMENT STATUS---

%---DIAGNOSTICS---
LOGFILE = diagnostics( fullfile(rootdir, 'logs', [mfilename '.log']) );
if ~exist('LOG_ARGS','var')
    LOG_ARGS = {};
end
if ~exist('LOG_DESCRIPTION','var')
    LOG_DESCRIPTION='none';
end
LOG = new_diagnostics_log( LOG_DESCRIPTION, LOG_ARGS{:} );
%---DIAGNOSTICS---

errobj = [];

try

    local_process();
    
    %---DIAGNOSTICS---
    LOG.status = 'complete';
    LOGFILE = addlog( LOGFILE, LOG );
    %---DIAGNOSTICS---
    
catch
   
    %get error
    errobj = lasterror;
  
    %---DIAGNOSTICS---
    LOG.status = 'fail';
    LOG.ERROR = configobj(errobj);
    LOGFILE = addlog( LOGFILE, setcomment(LOG, 'ABORTED', 'inline') );    
    %---DIAGNOSTICS---
  
end

%---DIAGNOSTICS---
write(LOGFILE);
%---DIAGNOSTICS---

if ~isempty(errobj)
    rethrow(errobj);
end

end



