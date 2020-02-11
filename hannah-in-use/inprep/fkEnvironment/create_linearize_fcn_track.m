function ctx = create_linearize_fcn_track( pp )
%CREATE_LINEARIZE_FCN_TRACK track linearization functions
%
%  ctx=CREATE_LINEARIZE_FCN_TRACK(ctx) For a set of linearization
%  contexts, this function will return a new linearization context
%  that is a concatenation of the contexts provided ("track"). This
%  structure contains the following fields:
%   length - (estimated) total length of the track
%   linearize - linearization function of the form:
%               [lpos,delta,segpos]=linearize(xy), this function
%               will take a nx2 matrix of x,y coordinates and
%               computes for each point the linearized position
%               (lpos) and the distance to the track (delta). In
%               addition, the function can return the linearized
%               position and index for the child contexts (segpos).
%   inv_linearize - inverse linearization function of the form:
%                   xy=inv_linearize(linpos[,delta]), this function
%                   will take a vector of linearized positions
%                   (linpos) and return the corresponding x,y
%                   coordinates on the track. Optionally, a vector
%                   with distances to the track (delta) can be
%                   provided, and the corresponding x,y coordinates
%                   will be offset from the track by that amount.
%   direction - local direction function of the form:
%               dir=direction(linpos), this function will take a
%               vector of linearized positions (linpos) and return
%               the angle of the track (dir) at those positions in
%               radians.
%   velocity - velocity function of the form:
%              vel=velocity(linpos[,dt]), this function will take a
%              vector of regularly sampled linearized positions and
%              returns the velocity. It will correctly deal with
%              transition between child contexts and with closed
%              child contexts. Optionally, a sample period (dt) can
%              be provided (default=1/30).
%   bin - binning function of the form:
%         [bins,nbins,binsize]=bin(binsize),this function will
%         return a vector of bin edges that span the complete track
%         with a bin size as close as possible to the desired bin
%         size. This function garantuees that bins never span the
%         boundaries between child contexts. This means that the
%         actual bin size for each child context may differ. The
%         function will also return the actual number of bins and
%         the bin size for each track component.
%   thicken - outlining function of the form: xy=thicken(width),
%             this function will create an outline of the track
%             with the specified width.
%   flatten - flattening function of the form:
%             ctx=flatten([factor,origin,startangle]), this
%             function will return a new linearization context of
%             the track flattened with the specified
%             factor. Optionally, the final origin and startangle 
%             can be specified.
%

%  Copyright 2007-2008 Fabian Kloosterman


%compute total length
L = sum( [pp.length] );

%create linearization context
ctx = struct( 'length', L, ...
              'linearize', @(xy) linearize_track(xy, pp), ...
              'inv_linearize', @(p,varargin) inv_linearize_track(p,pp,varargin{:}), ...
              'direction', @(p) direction_track(p,pp), ...
              'velocity', @(p, varargin) velocity_track(p, vertcat(pp.length), vertcat(pp.isclosed), varargin{:} ), ...
              'bin', @(binsize) bin_track(binsize,pp), ...
              'thicken', @(w) thicken_track(pp,w), ...
              'flatten', @(varargin) flatten_track(pp, varargin{:}) );
          
end

%------------------
%INTERNAL FUNCTIONS
%------------------

function [p2,d,p] = linearize_track(xy,pp)
%LINEARIZE_TRACK linearization function

%preallocate outputs
p = NaN( size(xy,1), 2 );
d = Inf( size(xy,1), 1 );

%loop through all polylines
for k=1:numel(pp)
    %linearize all x,y coordinates using this child context
    [tmp_p,tmp_d]=pp(k).linearize(xy);
    %test whether distance to child is smaller than anything we had
    %before and save the linearized position, distance and child index
    idx = find( abs(tmp_d)<abs(d) );
    p(idx,1) = tmp_p(idx);
    p(idx,2) = k;
    d(idx) = tmp_d(idx);
end

%for all valid points...
valid = ~isnan( p(:,1) );

%compute the linearized position
l = vertcat( pp.length );
csl = cumsum([0;l]);
p2 = NaN( size(p,1),1);
p2(valid) = p(valid,1) + csl( p(valid,2) );

end

%------------------

function xy = inv_linearize_track(p,pp,dist)
%INV_LINEARIZE_TRACK inverse linearization function

%convert linearized position to segmented linearized position
p = convert2seglinear( p, vertcat( pp.length ) );

%preallocate output
xy = NaN( size(p) );

%loop through all polylines
for k=1:numel(pp)
  %find points p on this child
  idx = find( p(:,2)==k );
  %inverse linearize
  if nargin>2
      xy(idx,:) = pp(k).inv_linearize( p(idx,1), dist(idx));
  else
      xy(idx,:) = pp(k).inv_linearize( p(idx,1) );
  end
end

end

%------------------

function d = direction_track(p,pp)
%DIRECTION_TRACK local track direction

%convert linearized position to segmented linearized position
p = convert2seglinear( p, vertcat( pp.length ) );

%preallocate output
d = NaN( size(p,1), 1 );

%loop through all polylines
for k=1:numel(pp)
  %find points p on that polyline
  idx = find( p(:,2)==k );
  %and compute direction
  d(idx) = pp(k).direction( p(idx,1) );
end

end

%------------------

function v = velocity_track(p, l, isclosed, dt)
%VELOCITY_TRACK compute linearized velocity

%convert linearized position to segmented linearized position
p = convert2seglinear( p, l );

%remove NaNs
invalid = isnan( p(:,1 ) );
tmp = p; tmp( invalid,:) = [];

%find transitions between child contexts
idx = find( diff( tmp(:,2) )~=0 );
tmp1 = round( tmp(idx,1)./l(tmp(idx,2)) );
tmp2 = round( tmp(idx+1,1)./l(tmp(idx+1,2)) );  

%compute correction values
cs = zeros( size(tmp,1), 1 );
cs(idx+1) = tmp1.*l(tmp(idx,2)) - tmp2.*l(tmp(idx+1,2));

cs = cumsum( cs );

cs2 = NaN( size(p,1), 1 );
cs2( ~invalid ) = cs;

%apply corrections
p = p(:,1) + cs2;

%for every part on a closed track, unwrap and adjust later positions
isclosed = find(isclosed);

for k=1:numel(isclosed)
   
    %find segments
    q = find(tmp(:,2)==isclosed(k));
    b = burstdetect( q, 'MinISI', 1, 'MaxISI', 1 );
    segs = [ q(b==1) q(b==3) ];

    factor = 2*pi*l(isclosed(k));
    
    for j=1:size(segs,1)
       oldval = p(segs(j,2));
       
       %unwrap
       p((segs(j,1)+1):segs(j,2)) = unwrap( factor.*p( segs(j,1):segs(j,2) ...
                                                       ) )./factor;
       
       % Unwrap 
       %       dp = diff(p(segs(j,1):segs(j,2)));                % Incremental phase variations
       % dps = mod(dp+0.5*l(isclosed(k)),l(isclosed(k))) - 0.5*l(isclosed(k));      % Equivalent phase variations in [-pi,pi)
       % dps(dps==-0.5*l(isclosed(k)) & dp>0) = 0.5*l(isclosed(k));     % Preserve variation sign for pi vs. -pi
       % dp_corr = dps - dp;              % Incremental phase corrections
       % dp_corr(abs(dp)<0.5*l(isclosed(k))) = 0;   % Ignore correction when incr. variation is < CUTOFF
 
       % Integrate corrections and add to P to produce smoothed phase values
       %p((segs(j,1)+1):segs(j,2)) = p((segs(j,1)+1):segs(j,2)) + cumsum(dp_corr);       
       
       %p(segs(j,1):segs(j,2)) = unwrap( p(segs(j,1):segs(j,2)), 0.5*l(isclosed(k)) );
       
       %update position after segment
       p((segs(j,2)+1):end) = p((segs(j,2)+1):end) + p(segs(j,2)) - oldval;
    
    end

end

%compute gradient
if nargin<4 || isempty(dt)
    v = gradient( p, 1./30 );
else
    v = gradient( p, dt );
end

end

%------------------

function [edges, nbins, binsize] = bin_track(binsize,pp)
%BIN_TRACK binning function

%compute number of bins separately for each child
l = vertcat( pp.length );
csl  = cumsum( [0;l] );
nbins = ceil( l./binsize );
binsize = l./nbins;

edges = [];

%loop through child contexts
for k=1:numel(pp)
  
    %compute bin edges for child
    edges = [edges linspace(csl(k),csl(k+1),nbins(k)+1) ];
  
end

end

%------------------

function s = thicken_track(pp,w)
%THICKEN_TRACK create track outline

s = {};

%loop through all child contexts
for k=1:numel(pp)
    
    %thicken child
    tmp = pp(k).thicken(w);
    
    if iscell(tmp)
        s = cat(1,s,tmp);
    else
        s{end+1} = tmp;
    end
end

end

%------------------

function xy = flatten_track(pp, n, origin, startangle)
%FLATTEN_TRACK create flattened track

%check arguments
if nargin<2 || isempty(n)
    n=0;
else
    %make sure 0<=n<=1
    n=min(max(n,0),1);
end

if nargin<3
    origin = [];
elseif ~isequal(size(origin),[1 2]) && ~isempty(origin)
    error('flatten_track:invalidArgument', 'Invalid origin')
end

if nargin<4 
    startangle = 0;
elseif ~isscalar(startangle)
    error('flatten_track:invalidArgument', 'Invalid start angle')
end

if isempty(origin)
    %set origin to first point of first child
    origin = pp(1).inv_linearize(0);
end

np = numel(pp);

L = cumsum( [pp.length] );

%flatten first child
xy(1) = pp(1).flatten(n, origin, startangle);

%flatten other childs
for k=2:np

    %based on start angle and origin we can compute the new origin
    %for this child
    new_origin = origin + L(k-1).*[cos(startangle) sin(startangle)];

    %flatten child
    xy(k) = pp(k).flatten(n, new_origin, startangle);
    
end

%create linearization context
xy = create_linearize_context('track', xy );

end

%------------------

function pout = convert2seglinear(p, l)
%CONVERT2SEGLINEAR helper function

%convert to distance along segment + segment number
if size(p,2)==1
  csl = cumsum( [0;l] );
  tmp = fix(interp1( csl, (1:(numel(l)+1))', p, 'linear', 'extrap' ));
  tmp(tmp>numel(l))=numel(l);
  valid = ~isnan(p);
  pout = NaN(size(p,1),2);
  pout(valid,:) = [p(valid)-csl(tmp(valid)) tmp(valid)];
else
    pout=p;
end

end