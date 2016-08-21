function f = ratemap_kde( xy, xyref, varargin )
%RATEMAP_KDE compute kernel density estimate of rate map
%
%  f=RATEMAP_KDE(x,x_ref) returns a function that will compute the
%  ratemap as a density based on a set of coordinates x and a population of
%  coordinates x_ref. (i.e. spike behavior and total behavior). Only 1d
%  case has been implemented.
%
%  f=RATEMAP_KDE(...,parm1,val1,...) uses specified options. Valid
%  options are:
%   BandWidth - band width for kde estimation (default=1)
%   SampleFreq - sampling frequency (default=30)
%

%  Copyright 2007-2008 Fabian Kloosterman

%check arguments
args = struct( 'BandWidth', 1, 'SampleFreq', 30 );
args = parseArgs(varargin, args);

if size(xy,2) ==1

    %1d case
    K = args.SampleFreq.*( numel(xy) )./( numel(xyref) );
    spike_density = @(x) ksdensity( xy, x, 'width', args.BandWidth);
    occupancy_density = @(x) ksdensity( xyref, x, 'width', args.BandWidth);

    f = @(x) K.*spike_density(x) ./ occupancy_density(x);
    
else
    
    error('Only 1d case is implemented')
    
end
