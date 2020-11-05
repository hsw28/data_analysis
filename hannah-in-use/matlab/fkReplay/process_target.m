function targets = process_target( Rinfo, targets )
%PROCESS_TARGET

posgrid = eval( Rinfo.posgrid );
dpos = mean( diff( posgrid ) ); %position bin size

%process each target
for k=1:numel(targets)
  
  %but only if we've computed it
  if ~targets(k).success
    continue
  end
  
  %since radon transform was computed using dx=dy=1, we'll have to
  %transform theta and rho values to reflect real dx and dy
  %(rho vecor is not transformed because the transformation is different
  %depending on theta)
  targets(k).thetamax_real = atan( tan( targets(k).thetamax ) .* (1-Rinfo.overlap).*Rinfo.timebin./dpos );
  targets(k).rhomax_real = targets(k).rhomax .* (1-Rinfo.overlap).*Rinfo.timebin .* cos(targets(k).thetamax_real) ./ cos( targets(k).thetamax );
  targets(k).theta_real = atan( tan( targets(k).theta ) .* (1-Rinfo.overlap).*Rinfo.timebin./dpos );
  
  %find mode and log sum of mode of estimate
  targets(k).mode = max( targets(k).estimate );
  targets(k).modelogsum = sum( log( targets(k).mode ) );   
  if isfield(targets,'estimate_vel')
    targets(k).mode_vel = squeeze( max( targets(k).estimate_vel))';
    targets(k).modelogsum_vel = sum( log( targets(k).mode_vel ),2 );        
  end
  
  %temporary variables
  %segment window length
  L = diff(targets(k).segment);

  %track size
  P = diff(posgrid([1 end]));
  
  %compute start and end times/positions of best fitting line
  [targets(k).linetime, targets(k).linepos] = lineboxintersect([targets(k).thetamax_real, ...
                      targets(k).rhomax_real], [-L/2 L/2 -P/2 P/2]);  
  
  targets(k).linetime = targets(k).linetime + mean(targets(k).segment);
  targets(k).linepos = targets(k).linepos + mean(posgrid);
  
  %flip times/positions if start time > end time
  if diff( targets(k).linetime ) < 0
    targets(k).linetime = fliplr(targets(k).linetime);
    targets(k).linepos = fliplr(targets(k).linepos);
  end   
  
  %replay direction is +1 for outbound, -1 for inbound
  targets(k).replay_dir = sign( -cot( targets(k).thetamax_real ));
  
  if isfield(targets, 'projection_vel')
    %replay map varies from -1 (dominated by inbound map) to 1 (dominated
    %by outbound map)
    targets(k).replay_map = nansum(diff(targets(k).projection_vel,1,2))./nansum(targets(k).projection_vel(:));
  else
    targets(k).replay_map = NaN;
  end
end
