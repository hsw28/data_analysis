function varargout = define_roi(varargin)
%DEFINE_ROI define named regions of interest
%
%  regions=DEFINE_ROI(parm1,val1,...) This function will present a gui in
%  which rectangles can be drawn to define named regions of interest. Valid
%  options are:
%   image - video image (default=[])
%   imagesize - 2x2 matrix with x and y size of image (default=[1
%               size(image,2); 1 size(image,1)])
%   regions - regions structure array, with fields 'name' and
%             'position'
%

%  Copyright 2008-2008 Fabian Kloosterman
    
%check and parse inputs
options = struct( 'image', [], 'imagesize', [], ...
                  'regions', struct('name', {}, 'position', {}) );

options = parseArgs(varargin,options);


if ~isempty(options.image)
  
  if ~isnumeric(options.image) || ndims(options.image)>3
    error('define_roi:invalidArgument', 'Invalid image')
  elseif size(options.image,3)>1
      %convert rgb image to gray scale
    options.image = rgb2gray(options.image);
  end
  
  if isempty(options.imagesize)
    options.imagesize = [1 1 ; fliplr(size(options.image))]';
  elseif ~isnumeric(options.imagesize) || ndims(options.imagesize)>2 || ...
        ~isequal(size(options.imagesize),[2 2])
    error('define_roi:invalidArgument', 'Invalid image size')
  end
  
end

if ~isstruct(options.regions) || ...
      ~all(ismember(fieldnames(options.regions),{'name','position'}))
  error('define_roi:invalidArgument', 'Invalid regions structure')
end


%create figure with gray scale colormap and custom delete function
hFig = figure('colormap',gray(256), 'DeleteFcn', @figure_delete);

%create axes
hAx = axes('Units', 'normalized', 'Position', [0.1 0.1 0.6 0.8], ...
           'Parent', hFig);

%create buttons
hBtn(1) = uicontrol('Units', 'normalized', 'Position', [0.75 0.8 0.2 0.1], ...
                    'Parent', hFig, 'String', 'Add region');
hBtn(2) = uicontrol('Units', 'normalized', 'Position', [0.75 0.65 0.2 0.1], ...
                    'Parent', hFig, 'String', 'Delete object');

%plot image
if ~isempty(options.image)
  hImg = imagesc( options.imagesize(1,:), options.imagesize(2,:), ...
                  options.image, 'parent', hAx, 'hittest', 'off'); %#ok
end

%plot regions
hRegions = [];
for k=1:numel(options.regions)
  hRegions(k) = irect( options.regions(k).position, 'need_selection', true);
  set(hRegions(k), 'EdgeColor', [0 0 1]);
end

%set figure and buton callbacks
set(hFig, 'WindowButtonDownFcn', @select );
set( hBtn(1), 'Callback', @addregion);
set( hBtn(2), 'Callback', @deleteobj);

%wait until figure is closed
uiwait(hFig);

%return regions
varargout = {options.regions};



  function figure_delete(hObj, eventdata) %#ok
  %FIGURE_DELETE figure delete function
   
  tmp = {};
  
  %collect roi info
  for k=1:numel(hRegions)
    tmp{k}.position = get(hRegions(k), 'position' );
    tmp{k}.name = options.regions(k).name;
  end
  %save in options
  if ~isempty(tmp)
    options.regions = vertcat( tmp{:} );
  end

  end
  
  function select(hObj, eventdata) %#ok
  %SELECT select roi
      
  %find hit object      
  hitobj = hittest(hObj);
  
  %select object if it is a region, and deselect all other regions
  if ismember(hitobj, hRegions )
    set( hRegions, 'Selected', 'off', 'EdgeColor', [0 0 1]);
    set(hitobj, 'Selected', 'on');
    set(hitobj, 'EdgeColor', [1 0 0] );
  end
  end

  
  function addregion(hObj, eventdata) %#ok
  %ADDREGION create a new region
  
  %change mouse pointer and disable buttons
  set(hFig, 'pointer', 'fullcrosshair');
  set( hBtn, 'Enable', 'off');
  
  %let user draw rectangle
  pos = getrect(hAx);
  
  if ~isempty(pos)
    %create new region structure
    options.regions(end+1).position = pos;
    options.regions(end).name = '';
    
    %create new interactive rectangle
    hRegions(end+1) = irect( options.regions(end).position, 'need_selection', true);
    set(hRegions(end), 'EdgeColor', [0 0 1])
    
    %let user enter unique name for region
    done=false;
    while ~done
      name = inputdlg({'Enter region name:'}, 'Region name', 1, {''}, ...
                      struct('WindowStyle', 'modal'));
      if ~isempty(name) && ~any(strcmp(name{1}, {options.regions.name}))
        done=true;
      end
    end
    options.regions(end).name = name{1};
  end
  
  %reset pointer and anble buttons
  set(hFig, 'pointer', 'arrow');
  set( hBtn, 'Enable', 'on');  
  
  end

  
  function deleteobj(hObj, eventdata) %#ok
  %DELETEOBJ delete selected region
  
  %find selected region
  idx = find( strcmp( get( hRegions, 'Selected'), 'on' ) );
  
  %delete region
  if ~isempty(idx)
    delete(hRegions(idx));
    hRegions(idx) = [];
    options.regions(idx) = [];
  end
  end

end