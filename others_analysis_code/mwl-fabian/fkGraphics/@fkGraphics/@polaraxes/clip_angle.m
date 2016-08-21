function t=clip_angle(h,t,clip,limits)
%CLIP_ANGLE clip angles
%
%  t=CLIP_ANGLE(h,angles) clip angles to angular limits of polar axes
%  h. Values outside the limits are set to NaN.
%
%  t=CLIP_ANGLE(h,angles,clip) specifies the clip method:
%   nan - clipped values are set to NaN
%   clip - clipped values are set to angular limits
%
%  t=CLIP_ANGLE(h,angles,clip,limits) uses the specified angular limits
%  rather than the limits of the polar axes.
%

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
  help('fkGraphics.polaraxes.clip_angle')
  return
end

if nargin<3 || isempty(clip)
  clip='nan';
elseif ~ischar(clip) || ~any(strcmpi(clip,{'nan','clip'}))
  error('polaraxes:clip_angle:invalidArgument', ...
        'Invalid clipping method')
end

if nargin<4 || isempty(limits)
  %make sure to get angular limits in radians
  limits = fkGraphics.getradians(h, 'AngleLim');
elseif ~isnumeric(limits) || numel(limits)~=2
  error('polaraxes:clip_angle:invalidArgument', ...
        'Invalid angular limits')
end

t = check_angle(t,limits,lower(clip));
