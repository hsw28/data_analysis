function r=clip_radius(h,r,clip)
%CLIP_RADIUS clip and normalize radius values
%
%  r=CLIP_RADIUS(h,radius) clip radius values and normalize to unit
%  circle for use in polar axes h. By default values outside the radial
%  limits of the axes are set to NaN.
%
%  r=CLIP_RADIUS(h,radius,clip) specifies the clip method:
%   nan - clipped values are set to NaN
%   zero - clipped values are set to zero
%   clip - clipped values are set to radial axes limits
%

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
  help('fkGraphics.polaraxes.clip_radius')
  return
end

if nargin<3 || isempty(clip)
  clip = 'nan';
elseif ~ischar(clip) || ~any(strcmpi(clip,{'nan','zero','clip'}))
  error('polaraxes:clip_radius:invalidArgument', ...
        'Invalid clipping method')
end

r = check_radius(r, h.RadialLim, h.RadialDir, lower(clip));