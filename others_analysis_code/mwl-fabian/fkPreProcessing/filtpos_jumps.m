function [data, stats] = filtpos_jumps(data, maxjump, maxlen)
%FILTPOS_JUMPS remove transient big jumps in data
%
%  data=FILTPOS_JUMPS(data, maxjump, maxlen) looks for sudden jumps in
%  diode position data. Jumps are defined as having an amplitude of at
%  least maxjump (default=7) and a maximum length (in samples) of maxlen
%  (default=75). Data during jumps are set NaN.
%
%  [data,stats]=FILTPOS_JUMPS(...) returns a structure with information
%  about the operation.   

%check input arguments
if nargin<2
    maxjump = 7;
end
if nargin<3
    maxlen = 75;
end

[n,c] = size(data); %#ok

%create stats struct
stats.arguments.maxjump = maxjump;
stats.arguments.maxlen = maxlen;

diode = {'diode0','diode0','diode1','diode1'};
diodedim = {'x','y','x','y'};

%for each column...
for d = 1:c
    
  %initialize variables
  last_valid = 1; %index of last element that was not in a jump
  found_jump = 0; %yes/no found a jump
  njumps = 0; %tally of number of jumps
  jump_idx = []; %#ok start and end indices of jumps
  
  %indices of valid elements
  v = find( ~isnan( data(2:end,d) ) )+1;
  
  for k = 1:numel(v)
    
    %compare current point to last valid point
    dx = v(k)-last_valid;
    dy = abs( data(v(k),d) - data(last_valid, d) );
    
    %have we found a jump?
    if ~found_jump && dy/dx > maxjump
      found_jump = 1;
    end
    
    %is the end of a jump?
    if found_jump && (dy <= maxjump || dx>=maxlen) %end of jump
      if dx<maxlen %valid jump
        data( (last_valid+1):(v(k)-1), d ) = NaN;
        njumps = njumps+1;
        jump_idx(njumps,1:2) = [last_valid+1 v(k)-1]; %#ok          
      end     
      found_jump = 0;
    end
      
    if ~found_jump
      last_valid = v(k);
    end

  end
  
  stats.(diode{d}).(diodedim{d}).njumps = njumps;
  stats.(diode{d}).(diodedim{d}).index = jump_idx;

end
