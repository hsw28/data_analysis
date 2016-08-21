function [data, stats] = filtpos_gapinterp(data, gapsize)
%FILTPOS_GAPINTERP linearly interpolation of small gaps
%
%  data=FILTPOS_GAPINTERP(data) linearly interpolate gaps of maximum
%  length 2 in diode position data.
%
%  data=FILTPOS_GAPINTERP(data,gapsize) uses the specified maximum gap
%  size.
%
%  [data,stats]=FILTPOS_GAPINTERP(...) returns a structure with
%  information about the operation.
%

%  Copyright 2005-2006 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(gapsize)
    gapsize = 2;
end

%create stats struct
stats.arguments.gapsize = gapsize;

diode = {'diode0','diode0','diode1','diode1'};
diodedim = {'x','y','x','y'};

%for each column...
for c = 1:size(data,2)
  
  %find NaNs and non-NaNs 
  invalid = isnan( data(:,c) );
  idx = find(invalid==0);
  invalid_idx = find(invalid);

  %interpolate
  data(:,c) = interp1(idx, data(idx,c), 1:size(data,1), 'linear');
  
  %find all gaps
  b = burstdetect( invalid_idx, 'MinISI', 1, 'MaxIsI', 1 );
  stats.(diode{c}).(diodedim{c}).ngaps = numel(find(b==1));%total number of gaps
  stats.(diode{c}).(diodedim{c}).ningap = numel(find(b>0));%total # invalid samples
  
  %filter out small gaps
  b = burstfilterlen( b, [gapsize+1 Inf] );
  stats.(diode{c}).(diodedim{c}).ngaps = stats.(diode{c}).(diodedim{c}).ngaps - numel(find(b==1));%subtract the big gaps
  stats.(diode{c}).(diodedim{c}).ningap = stats.(diode{c}).(diodedim{c}).ningap - numel(find(b>0));%subtract big gaps

  %reinstate big gaps
  data( invalid_idx( find(b) ), c) = NaN; %#ok
  
end
