function env = import_env( rootdir )
%IMPORT_ENV import environment data
%
%  env=IMPORT_ENV(rootdir)
%

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end


if exist( fullfile(rootdir, 'environment', 'environment.mat'), 'file' )
  
  env = load( fullfile( rootdir, 'environment', 'environment.mat') );
  
  if isfield( env, 'env' )
    env = env.env;
  end
    
  %transform regions
  for k=1:numel(env.definition.regions)
      env.definition.regions(k).nodes = T2D_transform(env.definition.regions(k).nodes, env.transforms.Tworld);
  end
  for k=1:numel(env.definition.polylines)
      env.definition.polylines(k).nodes = T2D_transform(env.definition.polylines(k).nodes, env.transforms.Tworld);
  end
  for k=1:numel(env.definition.circles)
      env.definition.circles(k).center = T2D_transform(env.definition.circles(k).center, env.transforms.Tworld);
      env.definition.circles(k).radius = env.scale.*env.definition.circles(k).radius;
  end
  
  %import video
  env.altvideo = import_video( rootdir );
  env.video = env.altvideo.video;
  env.altvideo = rmfield( env.altvideo, 'video');
  
  %transform image
  
  %construct position transformation function
  Tworld = env.transforms.Tworld';
  Tposflip = env.transforms.Tposflip';
  env.pixelpos2world = @(p) T2D_transform(p, Tworld*Tposflip);
  env.world2pixelpos = @(p) T2D_transform(p, (Tworld*Tposflip)\eye(3));
  env.pos2world = @(p) T2D_transform(p, Tworld);
  env.world2pos = @(p) T2D_transform(p, Tworld\eye(3) );
  
  
  if ~isempty( env.video.still )
      Timgflip = env.transforms.Timgflip';
      Timg = env.transforms.Timg';
      scale = env.scale;
      
      env.image2world = @(img,varargin) imtransform( img, maketform('affine',(Tworld*Timg*Timgflip)'), 'nearest', 'xyscale', scale, varargin{:});
      env.imagepos2world = @(p) T2D_transform(p, Tworld*Timg*Timgflip);
      
      xdata = [1 size(env.video.still,2)];
      ydata = [1 size(env.video.still,1)];
      
      [env.video.still, udata, vdata] = env.image2world(env.video.still);
      
      env.video.image_xdata = udata;
      env.video.image_ydata = vdata;
      
      env.worldimage2image = @(img,varargin) imtransform( img, maketform('affine',((Tworld*Timg*Timgflip)\eye(3))'),...
          'xyscale',1,'udata',udata,'vdata',vdata,...
          'xdata',xdata,'ydata',ydata,varargin{:});
      
      env.world2image = @(p) T2D_transform( p, (Tworld*Timg*Timgflip)\eye(3) );
      
      %transform ROIs
      for r = 1:numel(env.video.roi)
          
          pos = env.video.roi(r).position;
          pos = env.imagepos2world( [pos([1 2]) ; pos([1 2])+[0 pos(4)]; pos([1 2])+[pos(3) 0]; pos([1 2])+pos([3 4])] );
          pos = [min(pos(:,1)) min(pos(:,2)) max(pos(:,1)) max(pos(:,2))];
          env.video.roi(r).position = [pos([1 2]) pos([3 4])-pos([1 2])];
          
      end
      
      
  end
  
else
  
  env = [];
  
end

if isempty(env)
  verbosemsg('No environment definition found.')
end