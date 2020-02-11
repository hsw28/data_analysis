function b=isseg(s)
%ISSEG test if input is valid list of segments
%
%  b=ISSEG(s) return true if input s is a valid list of segments
%

if ~isnumeric(s) || ndims(s)~=2 || size(s,2)~=2 || any( diff(s,[],2)<0 )
    b = false;
else
    b = true;
end