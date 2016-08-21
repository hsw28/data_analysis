function varargout = seg_overlap( A,B )
%SEG_OVERLAP compute overlap between segments
%
%  [overlap,rel1,rel2]=SEG_OVERLAP(a) returns the absolute overlap
%  and overlap fraction (relative to length of first or second segment)
%  between all combinations of segments in a.
%
%  [overlap,rel1,rel2]=SEG_OVERLAP(a,b) returns the absolute overlap
%  and overlap fraction (relative to length of first or second segment)
%  between all combinations of segments in a and b.  
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if nargin==1
  B=A;
end

%check for valid positive length (incl. 0 ) segments
if ( ~isnumeric(A) || ndims(A)~=2 || size(A,2)~=2 || any(diff(A,1,2)<0) ) || ...
      ( ~isnumeric(B) || ndims(B)~=2 || size(B,2)~=2 || any(diff(B,1,2)<0)),    
  error('segoverlap:invalidArgument', 'Invalid segments')
end

nA = size(A,1);
nB = size(B,1);

LA = repmat( diff(A,1,2), 1, nB );
LB = repmat( diff(B,1,2)', nA, 1 );

delta = repmat( mean(B,2)', nA, 1 ) - repmat( mean(A,2), 1, nB );

varargout{1} = max( 0, min( -abs(delta) + 0.5*abs( LB-LA), 0 ) + min( LA, LB ) );

varargout{2} = varargout{1} ./ LA;
varargout{3} = varargout{1} ./ LB;
