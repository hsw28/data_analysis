function L = create_openfield_path( nLoc, nVisits, nextLoc)
%CREATE_OPENFIELD_PATH create a random path
%
%  Syntax
%
%      P = create_openfield_path( nLoc, nVisits, nextLoc )
%
%  Description
%
%    Returns a vector of numbers between 1 and nLoc, where each number
%    occurs at most nVisits times. nextLoc determines the valid next
%    locations relative to the current location. Due to the random nature
%    and the nextLoc restriction, it is possible that not all locations
%    are visited exactly nVisits times.
%
%  Examples
%
%    P = create_openfield_path( 12, 12, 3:9 )
%

%  Copyright 2005-2008 Fabian Kloosterman
 
%check input arguments
if nargin<1 || isempty(nLoc)
  nLoc = 12;
end

%find first location
L = randsample( 1:nLoc, 1);

if nargin<3 || isempty(nextLoc)
  nextLoc = 3:9;
end

if nargin<2 || isempty(nVisits)
  nVisits = 15;
end

%keep track of remaining visits
nRemainVisits = zeros(nLoc,1)+nVisits;
nRemainVisits( L(end) ) = nRemainVisits( L(end) ) - 1;

%create path
while 1
  
  validLoc = mod( L(end) + nextLoc - 1, nLoc ) + 1;
  
  %is there any location left we can visit?
  if all( nRemainVisits(validLoc)==0 )
    break;
  end
  
  %find next location
  L(end+1) = randsample( validLoc, 1, true, nRemainVisits(validLoc) );
  nRemainVisits( L(end) ) = nRemainVisits( L(end) ) - 1;
  
end
