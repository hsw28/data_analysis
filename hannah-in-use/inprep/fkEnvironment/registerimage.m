function varargout = registerimage(img, pos, varargin)
%REGISTERIMAGE register an image with position data
%
%  [s,t]=REGISTERIMAGE(image) displays a gui in which the user can
%  rotate, scale and translate the image. The function returns the
%  structure s with the rotation angle, the scaling factor and the amount
%  of translation. The returned argument t is the transformation matrix.
%
%  [s,t]=REGISTERIMAGE(image,xy) plost the xy data on top of the
%  figure. Only the image is transformed.
%
%  [s,t]=REGISTERIMAGE(image,xy,param1,val1,...) additional options can
%  be specified. Valid options are:
%   Rotate - initial rotation (degrees)
%   Scale - initial scaling factor, either a scalar or a two-element
%           vector for seperate x and y scaling factors
%   Translate - initial translation, either a scalar or a two-element
%               vector for separate x and y translation
%

%  Copyright 2005-2006 Fabian Kloosterman

if nargin<1 || isempty(img)
  help(mfilename)
  return
end

if nargin<2
  pos = [];
end

args = struct('Scale', [1 1], 'Translate', [0 0], 'Rotate', 0);
args = parseArgs(varargin, args);

T = T2D_identity;

%convert image to grayscale
if size(img,3)>1
  img = rgb2gray(img);
end

%create main figure
hFig = create_main_figure();
ui = struct();
mod_mode = 0;
mod_mode_label = {'ROTATE', 'SCALE', 'TRANSLATE'};

try
  %layout main figure
  layout_main_figure();
  init()
  
catch
  delete(hFig); 
  rethrow( lasterror )
  return
end

waitfor(hFig);


%===================================================
%      nested functions
%===================================================


  function hFig = create_main_figure()
  hFig = figure('NextPlot', 'new', 'Name', 'image registration - ROTATE', ...
                'toolbar', 'none', 'MenuBar', 'none', 'CloseRequestFcn', ...
                @close_main_figure, 'Color', [0.9 0.9 1], 'NumberTitle', 'off');
  colormap gray;
  end

  function close_main_figure( hFig, eventdata )  %#ok
  %uiresume(hFig);
  varargout{1} = struct('rotation', args.Rotate, 'scale', args.Scale, 'translation', args.Translate);
  varargout{2} = T';
  delete(hFig);
  end

  function layout_main_figure()
  
  cheight = 2;
  cwidth = 20;
  h = 6;
  
  sz = get(0, 'ScreenSize');
  set(hFig, 'Position', [sz(3)/4 sz(4)/4 sz(3)/2 sz(4)/2]);

  ui.panel = axismatrix( 1,2,'Parent', hFig, 'Fcn', @uipanel, 'YOffset', ...
                         1, 'XOffset', 2, 'YSpacing', 1, 'XSpacing', 2, ...
                         'Width', [1 -2*cwidth], 'ArgIn', {'BorderType', 'none'});
  ui.panel(3) = axismatrix( 1,1, 'Parent', ui.panel(2), 'Fcn', @uipanel, ...
                           'YOffset', 1, 'XOffset', 0, 'YSpacing', 1, ...
                           'XSpacing', 0, 'Width', -2*cwidth, 'Height', -(4+h)*cheight, 'ArgIn', ...
                            {'BorderType', 'none'} );

  ui.rotate = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                        'Position', [cwidth (3+h)*cheight cwidth cheight], 'String', '', 'Style', 'edit');
  ui.rotate_label = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                              'Position', [0 (3+h)*cheight cwidth cheight], 'String', 'Rotation', 'Style', 'text');
  ui.scale = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                       'Position', [cwidth (2+h)*cheight cwidth cheight], 'String', '', 'Style', 'edit');
  ui.scale_label = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                             'Position', [0 (2+h)*cheight cwidth cheight], 'String', 'Scaling', 'Style', 'text');
  ui.translate = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                           'Position', [cwidth (1+h)*cheight cwidth cheight], 'String', '', 'Style', 'edit');
  ui.translate_label = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                                 'Position', [0 (1+h)*cheight cwidth cheight], 'String', 'Translation', 'Style', 'text');
  ui.refresh = uicontrol('Parent', ui.panel(3), 'Units', 'characters', ...
                         'Position', [0 h*cheight 2*cwidth cheight], 'String', 'Refresh', 'Callback', @refreshimage);

  ui.help = uicontrol('Parent', ui.panel(3), 'Units', 'characters', 'Style', 'text',...
                      'Position', [0 0 2*cwidth h*cheight], 'String', ...
                      { 'Type ''m'' to toggle between rotate, scale and translate mode.', ...
                      'Use scroll wheel to transform image.', ...
                      'Hold ''shift'' to change x-axis only.', ...
                      'Hold ''control'' to change y-axis only.', ...
                      'Drag left mouse button to make measurements.'}, 'FontAngle', ...
                      'italic', 'HorizontalAlignment', 'left', 'ForegroundColor', ...
                      [0 0 1]);
  
  ui.axis = axes('Parent', ui.panel(1), 'Units', 'normalized');
  
  event_dispatch( hFig );
  enable_events( ui.axis );

  add_callback( ui.axis, 'MyWheelMovedFcn', @wheelfcn );
  add_callback( hFig, 'MyKeyPressFcn', {@mode_change} );
  
  ruler( ui.axis, 'Button', 1, 'TextProps', {'BackgroundColor', [1 1 1], 'Color', [0 ...
                      0 1], 'FontAngle', 'italic'}, 'LineProps', {'Color', [1 0.5 0], 'LineWidth', 2} );
  
  %set( hFig, 'KeyPressFcn', @mode_change );
  
  end
  
  function retval = mode_change( hObj, eventdata ) %#ok
    c = get( hObj, 'CurrentCharacter');
    retval = 0;
    if c == 'm'
      mod_mode = mod( mod_mode + 1, 3 );
      set( hFig, 'Name', ['image registration - ' mod_mode_label{mod_mode+1}] );
      retval = 1;
    end
  end
  
  function retval = wheelfcn(hObj, eventdata) %#ok
    
    shift_mask = bitand( 1, eventdata.Modifiers );
    ctrl_mask = bitand( 2, eventdata.Modifiers );
    
    factor = eventdata.WheelRotation;
    
    switch mod_mode
     case 0 %rotate
      args.Rotate = mod(args.Rotate + factor, 360);
      set(ui.rotate, 'String', num2str(args.Rotate));           
     case 1 %scale
      if shift_mask && ~ctrl_mask
        args.Scale(1) = args.Scale(1).*(1.01.^factor);
      elseif ctrl_mask && ~shift_mask
        args.Scale(2) = args.Scale(2).*(1.01.^factor);
      else
        args.Scale = args.Scale.*(1.01.^factor);        
      end
      set(ui.scale, 'String', num2str(args.Scale));           
     case 2 %translate
      if shift_mask && ~ctrl_mask
        args.Translate(1) = args.Translate(1) + factor;
      elseif ctrl_mask && ~shift_mask
        args.Translate(2) = args.Translate(2) + factor;
      else
        args.Translate = args.Translate + factor;
      end      
      set(ui.translate, 'String', num2str(args.Translate));    
    end

    updateimage();
    
    retval = 1;
  end
  
  function refreshimage( hObject, eventdata ) %#ok
  
  args.Rotate = str2num( get( ui.rotate, 'String') ); %#ok
  args.Scale = str2num( get( ui.scale, 'String') ); %#ok
  if isscalar(args.Scale)
    args.Scale = [args.Scale args.Scale];
  end
  args.Translate = str2num( get( ui.translate, 'String') ); %#ok
  if isscalar(args.Translate)
    args.Translate = [args.Translate args.Translate];
  end
  updateimage();
  
  releasefocus(hObject);
  
  end

  function updateimage( )
  
  %center of rotation
  sz = fliplr( size(img) ) - 1;
  c = sz ./ 2;
  %create identity matrix
  T = T2D_identity();
  %rotate
  T = T2D_rotate( args.Rotate*pi/180, T, c );
  %scale
  T = T2D_scale( args.Scale, T);
  %translate
  T = T2D_translate( args.Translate , T);
  %make matlab affine transformation matrix
  Tform = maketform('affine', T');
  %transform image
  [Timg, Tx, Ty] = imtransform(img, Tform);
  
  %[Timg, Tx, Ty] = transform_image(img, args.Rotate, args.Scale, args.Translate);
  
  set(ui.img, 'XData', Tx, 'YData', Ty, 'CData', Timg);
  
  end

  function init( )
    
  %fill ui controls
  set(ui.rotate, 'String', num2str(args.Rotate));
  set(ui.scale, 'String', num2str(args.Scale));
  set(ui.translate, 'String', num2str(args.Translate));
  
  %draw image
  ui.img = imagesc( img, 'Parent', ui.axis, 'HitTest', 'off');
  
  set( ui.axis, 'TickDir', 'out', 'YDir', 'normal');
  
  if ~isempty(pos)
    %draw map of position data
    mm = map( pos, 'Grid', { 0:2:328, 0:2:254 } );
    plot_map2D( mm, 'Parent', ui.axis, 'Alpha', 0.5, 'MapEdges', { 0:2:328, 0:2:254 }, 'ColorMap', jet(256) );
    
    %draw position data
    %line( pos(:,1), pos(:,2), 'Parent', ui.axis, 'Color', [1 0.5 0.25]);
  end
  
  updateimage();
  end


end