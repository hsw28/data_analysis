function varargout = general_radon_c( varargin ) %#ok
%GENERAL_RADON_C mex function for radon transform
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy) computes the radon transform of
%  matrix m with nearest neighbor interpolation for all lines defined by
%  all possible theta/rho pairs. Dx and dy are define the sample spacing
%  in the x (row) and y (column) dimensions.
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy,interp) if interp is 1 the radon
%  algorithm uses linear interpolation between the elements of matrix m.
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy,interp,method) chooses the method
%  to combine the matrix elements along a line. Possible values are:
%  0=integral, 1=sum, 2=mean, 3=slice, 4=product. If method is 'slice',
%  then theta and rho should be equal length vectors and a cell array is
%  returned with for each theta/rho pair the projection along the line.
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy,interp,method,constraint) if
%  constraint is 0 (default) then the algorithm will loop over the x
%  (row) dimension or y (column) dimension depending on the angle of the
%  line (e.g. for vertical lines, the algorithm should loop over the y
%  dimension, whereas for horizontal lines it should loop over the x
%  dimension). If constraint=1, then the algorithm will always loop over
%  the x (row) dimension; if constraint=2, the algorithm will always loop
%  over the y (column) dimension.
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy,interp,method,constraint,valid) if
%  valid=1, only those lines which span the complete width and/or height
%  of the matrix are considered.
%
%  r=GENERAL_RADON_C(theta,rho,m,dx,dy,interp,method,constraint,valid,rho_x)
%  if rho_x=1 then the values of rho are interpreted as the intercept
%  with the horizontal center line, rather than the distance from the
%  origin. This could be useful if you want rho to be in the same units
%  as the x dimension. Notice however, that in this mode, rho will go to
%  infinity if theta approaches +/- pi.
%
