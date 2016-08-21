function x=padvector(x, np, pad)
%PADVECTOR pad a vector
%
%  x=PADVECTOR(x,npoints) pads a vector with zeros. If npoints is a scalr
%  it specifies the number of zeros to be padded at either end of x. If
%  npoints is a two-element vector, it specifies the number of zeros to
%  add to the start and end of x respectively.
%
%  x=PADVECTOR(x,npoints,value) pads with value instead of zeros.
%
%  x=PADVECTOR(x,npoints,'replicate') repeats border elements of x.
%
%  x=PADVECTOR(x,npoints,'symmetric') pads vector with mirror reflections
%  of itself.
%
%  x=PADVECTOR(x,npoints,'circular') pads with circular repetition of
%  elements.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
  help(mfilename)
  return
end

if nargin<3
  pad = 0;
end

nx = numel(x);

switch pad
 case 'replicate'
  idx = [ones(np(1),1) ; (1:nx)' ; zeros(np(end),1)+nx];
  x = x(idx);
 case 'symmetric'
  idx = [ 1+(np(1):-1:1)' ; (1:nx)' ; nx-(1:np(end))'];
  x = x(idx);
 case 'circular'
  idx = [ nx-(np(1):-1:1)'+1 ; (1:nx)' ; (1:np(end))' ];
  x = x(idx);
 otherwise
  idx = [ones(np(1),1) ; (1:nx)' ; zeros(np(end),1)+nx];
  x = x(idx);
  x(1:np(1)) = pad;
  x(end-np(end)+1:end) = pad;
end

