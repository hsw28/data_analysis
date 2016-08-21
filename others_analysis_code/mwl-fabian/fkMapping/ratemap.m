function [rm,g,om]=ratemap(spike_behavior, behavior, varargin)
%RATEMAP create rate maps
%
%  ratemaps=RATEMAP(spike_behavior,behavior) computes the non-smoothed
%  rate maps from a the behavior at spike times and the complete
%  behavior.
%
%  ratemaps=RATEMAP(...,parm1,val1,...) uses specified options. Valid
%  options are:
%   grid - mapping grid
%   smooth - st.dev. of smoothing kernels
%   samplefreq - sampling frequency
%   normalize - true/false return rate or counts
%
%  [ratemaps,grid,occupancy]=RATEMAP(...) also returns the grid and
%  occupancy map.
%

%  Copyright 2007-2008 Fabian Kloosterman

%check arguments
if nargin<2
  help(mfilename)
  return
end

options = struct( 'smooth', [], 'samplefreq', 30, 'grid', [], 'normalize', true);
[options, other, remainder] = parseArgs(varargin,options); %#ok

%create occupancy map and grid
[om, g] = map( behavior, remainder{:}, 'grid', options.grid );

%get sample spacing in grid
dx = deltas(g);
dx(isnan(dx)|isinf(dx))=1;

%smooth if requested
if ~isempty( options.smooth ) && any(options.smooth~=0)
  om = smoothn( om, options.smooth, dx, 'nanexcl', 1, 'correct', 1 );
end

%convert occupancy to seconds
om = om ./ options.samplefreq;

%compute spike behavior maps
rm = map( spike_behavior, remainder{:}, 'grid', g, 'default', 0 );

%smooth if requested
if ~isempty( options.smooth ) && any(options.smooth~=0)
  rm = smoothn( rm, [options.smooth 0], [dx 1] );
end

%compute rate map
if options.normalize
    rm = bsxfun(@rdivide,rm,om);
end
