function val=getAngleData(h,val)
%SETANGLEDATA conversion setter function
%
%  val=SETANGLEDATA(h,val)
%


if strcmp(h.AngleUnits,'degrees') && ~ischar(val)
  %convert to degrees
  val=val*180/pi;
end