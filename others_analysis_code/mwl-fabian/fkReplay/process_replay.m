function [R,Rrank]  = process_replay(R, varargin)
%PROCESS_REPLAY process results of replay detection
%
%  [r,rank]=PROCESS_REPLAY(r)
%
%  [r,rank]=PROCESS_REPLAY(r,parm1,val1,...)
%   xypos - xy coordinates of animal
%   headdir - head direction of animal
%   lindir - linear direction of animal
%   invlin - inverse linearization function
%

options = struct( 'xypos', [], 'headdir', [], 'lindir', [], 'invlin', []);
options = parseArgs(varargin, options);

posgrid = eval( R.info.posgrid );
dpos = mean( diff( posgrid ) ); %position bin size
  
%process each target
for k=1:numel(R.target)
  
  %but only if we've computed it
  if ~R.target(k).success
    continue
  end
  
  %find number of timebins of estimate
  R.target(k).nbins = size( R.target(k).estimate, ndims(R.target(k).estimate) );
   
  %since radon transform was computed using dx=dy=1, we'll have to
  %transform theta and rho values to reflect real dx and dy
  %(rho vecor is not transformed because the transformation is different
  %depending on theta)
  R.target(k).thetamax_real = atan( tan( R.target(k).thetamax ) .* R.info.timebin./dpos );
  R.target(k).rhomax_real = R.target(k).rhomax .* R.info.timebin .* cos(R.target(k).thetamax_real) ./ cos( R.target(k).thetamax );
  R.target(k).theta_real = atan( tan( R.target(k).theta ) .* R.info.timebin./dpos );
  
  %find mode and log sum of mode of estimate
  R.target(k).mode = max( R.target(k).estimate );
  R.target(k).modelogsum = sum( log( R.target(k).mode ) );   
  if isfield(R.target,'estimate_vel')
    R.target(k).mode_vel = squeeze( max( R.target(k).estimate_vel))';
    R.target(k).modelogsum_vel = sum( log( R.target(k).mode_vel ),2 );        
  end
  
  %temporary variables
  %segment window length
  L = diff(R.target(k).segment);
  %track size
  P = diff(posgrid([1 end]));
  
  %compute start and end times/positions of best fitting line
  [R.target(k).linetime, R.target(k).linepos] = lineboxintersect([R.target(k).thetamax_real, ...
                      R.target(k).rhomax_real], [-L/2 L/2 -P/2 P/2]);  
  
  R.target(k).linetime = R.target(k).linetime + mean(R.target(k).segment);
  R.target(k).linepos = R.target(k).linepos + mean(posgrid);
  
  %flip times/positions if start time > end time
  if diff( R.target(k).linetime ) < 0
    R.target(k).linetime = fliplr(R.target(k).linetime);
    R.target(k).linepos = fliplr(R.target(k).linepos);
  end   
  
  %replay direction is +1 for outbound, -1 for inbound
  R.target(k).replay_dir = sign( -cot( R.target(k).thetamax_real ));
  %replay map varies from -1 (dominated by inbound map) to 1 (dominated
  %by outbound map)
  R.target(k).replay_map = nansum(diff(R.target(k).radon_projection_vel,1,2))./nansum(R.target(k).radon_projection_vel(:));

  %if R.target(k).replay_dir==-1
  %  R.target(k).radon_projection = flipud( R.target(k).radon_projection);
  %  R.target(k).radon_projection_vel = flipud( R.target(k).radon_projection_vel);    
  %end    
  
  %----------------------
  %---COMPUTE P-VALUES---
  %----------------------
  %
  % we'll compute upper bound p-values non-parametrically
  %
 
  R.target(k).pvalue = NaN;
  
  %compute p-values for randcycle shuffles
  if isfield( R, 'shufflecycle' ) && ~isempty(R.shufflecycle(k).radonmax)
    
    %R.target(k).pcycle = min(1,(numel( find( R.shufflecycle(k).radonmax > R.target(k).radonmax ) )+1) ./ numel( R.shufflecycle(k).radonmax ));
    R.target(k).pcycle = (1 + numel( find( R.shufflecycle(k).radonmax >= R.target(k).radonmax ) ) )./ (numel( R.shufflecycle(k).radonmax )+1);
    R.target(k).pvalue = max( R.target(k).pvalue, R.target(k).pcycle );
    
  end
  
  %compute p-values for clperm shuffles
  if isfield( R, 'shuffleclperm') && ~isempty(R.shuffleclperm(k).radonmax)

    %R.target(k).pclperm = min(1,(numel( find( R.shuffleclperm(k).radonmax > R.target(k).radonmax ) )+1) ./ numel( R.shuffleclperm(k).radonmax ));
    R.target(k).pclperm = (1 + numel( find( R.shuffleclperm(k).radonmax >= R.target(k).radonmax ) ) )./ (numel( R.shuffleclperm(k).radonmax )+1);
    R.target(k).pvalue = max( R.target(k).pvalue, R.target(k).pclperm );
    
  end
  
  %compute p-values for pseudo shuffles
  if isfield( R, 'shufflepseudo') && ~isempty(R.shufflepseudo(R.target(k).nbins).radonmax)
    
    %R.target(k).ppseudo = min(1,(numel( find( R.shufflepseudo(R.target(k).nbins).radonmax > R.target(k).radonmax ) )+1) ./ numel( R.shufflepseudo(R.target(k).nbins).radonmax ));    
    R.target(k).ppseudo = (1 + numel( find( R.shufflepseudo(R.target(k).nbins).radonmax >= R.target(k).radonmax ) ) )./ (numel( R.shufflepseudo(R.target(k).nbins).radonmax )+1);
    R.target(k).pvalue = max( R.target(k).pvalue, R.target(k).ppseudo );
    
  end
  

  
  %----------------------
  %---COMPUTE BEHAVIOR---   
  %----------------------
  % animal linear position, xy position, head direction
  % replay xy position, replay xy distance to animal
  % angle between replay xy position and animal position
  % animal head direction relative to track
  
  %animal linear position
  R.target(k).animal_linpos = interp1( R.info.behavior.time, ...
                                       R.info.behavior.variables(:,1), ...
                                       mean( R.target(k).segment ), ...
                                       'nearest');
  
  %animal xy position
  if ~isempty( options.xypos )
    R.target(k).animal_xypos = interp1( R.info.behavior.time, ...
                                        options.xypos, ...
                                        mean( R.target(k).segment ), ...
                                        'nearest');                                        
  else
    R.target(k).animal_xypos = [NaN NaN];
  end
  
  %animal head direction
  if ~isempty( options.headdir )
    R.target(k).animal_headdir = interp1( R.info.behavior.time, ...
                                          options.headdir, ...
                                          mean( R.target(k).segment ), ...
                                          'nearest' );
  else
    R.target(k).animal_headdir = NaN;
  end
  
  %xy position of replay start and end
  if ~isempty( options.invlin )
    R.target(k).replay_xypos = options.invlin( R.target(k).linepos );
  else
    R.target(k).replay_xypos = [NaN NaN];
  end
  
   
  R.target(k).replay_dist_to_animal = sqrt( (R.target(k).replay_xypos(:,1)-R.target(k).animal_xypos(1)).^2 + ...
                                            (R.target(k).replay_xypos(:,2)-R.target(k).animal_xypos(2)).^2 );

  
  R.target(k).replay_angle_to_animal = atan2((R.target(k).replay_xypos(:,2)-R.target(k).animal_xypos(2)),(R.target(k).replay_xypos(:,1)-R.target(k).animal_xypos(1)));
  
  %animal linear head direction (i.e. relative to track)
  if ~isempty( options.lindir )
    R.target(k).animal_lindir = interp1(R.info.behavior.time, ...
                                        options.lindir, ...
                                        mean(R.target(k).segment), ...
                                        'nearest')*pi/180;  
  else
    R.target(k).animal_lindir = NaN;
  end
  
end


%-------------------
%---COMPUTE RANKS---
%-------------------

%find all segments that have been processed
valid = find([R.target.success]==1);

%rank by p-value
[dummy, Rrank.pvalue] = sort( [R.target.pvalue]); %#ok
Rrank.pvalue=valid(Rrank.pvalue);

%rank by radon max value
[dummy, Rrank.radonmax] = sort( [R.target.radonmax], 'descend' ); %#ok
Rrank.radonmax=valid(Rrank.radonmax);

%rank by log sum of mode
[dummy, Rrank.modelogsum] = sort( [R.target.modelogsum], 'descend' ); %#ok
Rrank.modelogsum=valid(Rrank.modelogsum);


return
   
   
