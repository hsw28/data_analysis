function  trajects=traject_fcn(  xy,  incl,  excl,  order,  revisit)
%TRAJECT_FCN find trajectories in position data
%
%  trajects=TRAJECT_FCN(xy,incl) Find trajectories in the position data
%  xy, given the regions in incl. At least two include regions (start and
%  end) are required. The function returns the start and end indices into
%  the xy matrix for each trajectory. For a particular trajectory to be
%  valid, it has to go through all regions in the specified order,
%  revisits are not allowed. Include regions are specified as a cell
%  array of x,y nodes that define a polygon.
%
%  trajects=TRAJECT_FCN(xy,incl,excl) Adds a set of exclusive
%  regions. Valid trajectories do not go through any of these regions.
%
%  trajects=TRAJECT_FCN(xy,incl,excl,order) Where order is true or false,
%  specifies whether the order of inclusive regions is important or
%  not. Note that the first and last include regions are always taken as
%  the start and end of a trajectory.
%
%  trajects=TRAJECT_FCN(xy,incl,excl,order,revisit) Where revisit is true
%  or false, specifies whether immediate revisits of a particular region
%  is allowed.
%

%  Copyright 2007-2008 Fabian Kloosterman


if nargin<2 || isempty(incl)
  incl = {};
end

if nargin<3 || isempty(excl)
  excl = {};
end

if nargin<4 || isempty(order)
  order = true;
end

if nargin<5 || isempty(revisit)
  revisit = false;
end

n_incl = numel(incl);
n_excl = numel(excl);

if n_incl<2
  error('traject_fcn:invalidArguments', 'Need at least two include regions');
end

start_region = inpolygon( xy(:,1), xy(:,2), incl{1}(:,1), incl{1}(:,2));
end_region = inpolygon(xy(:,1), xy(:,2), incl{end}(:,1), incl{end}(:,2));

start_transitions = diff(start_region);
end_transitions = diff(end_region);

start_exits = find( start_transitions == -1 );
end_entries = find( end_transitions == 1) + 1;

if revisit
  %do greedy start/end
  trajects = event2seg(start_exits, end_entries, ...
                       'GreedyStart', true, ...
                       'GreedyEnd', true);  
else
  trajects = event2seg(start_exits, end_entries);
end

if ~isempty(trajects) && n_incl>2
  %check other inclusive regions
  
  %loop through trajectories backwards
  for t = size(trajects,1):-1:1
    
    traject_xy = xy(trajects(t,1):trajects(t,2),:);
    
    valid = zeros(size(traject_xy,1),1);
    
    %loop through remaining inclusive regions
    for i = 2:(n_incl-1)
        
      %find positions in region
      inreg = find( inpolygon( traject_xy(:,1), traject_xy(:,2), ...
                               incl{i}(:,1), incl{i}(:,2) ) );
      
      if isempty(inreg)
        %don't even bother to continue, this traject is invalid
        trajects(t,:) = [];
        valid = [];
        break;
      end
      
      valid( inreg ) = i;
      
    end
    
    if ~isempty(valid) && order
      %diff the valid vector
      valid = valid( find( diff(valid)>0 ) + 1);
      %do another diff...
      valid = diff(valid);
      if revisit
        valid(valid==0) = [];
      end
      if ~all( valid==1 )
        %invalid traject
        trajects(t,:) = [];
      end
      
    end
  end
end


if ~isempty(trajects)
  %check exclusive regions
  if n_excl>0
    
    for t = size(trajects,1):-1:1
      
      traject_xy = xy(trajects(t,1):trajects(t,2),:);
      
      for i = 1:n_excl
        
        if any( inpolygon( traject_xy(:,1), traject_xy(:,2), excl{i}(:,1), ...
                           excl{i}(:,2) ) )
          trajects(t,:)=[];
        end
      end
    end
  end
end

