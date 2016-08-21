function vel = calculate_velocity(lin_pos, smooth_std, fs)
% CALCULATE_VELOCITY(linear_position, thresholde)
% 
% returns a vector of velocity (in the same units as lin_pos) any
% velocities below threshold are returned as 0 


vel = gradient(lin_pos, fs); % calculate velocity;
vel(isnan(vel))=0;
               
vel(abs(vel)>1.5) = 0; % remove outliers


                
vel = smoothn(vel, smooth_std, fs);
        