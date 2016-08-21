function val=getdegrees(h,prop)
%GETDEGREES helper function
%
%  val=GETDEGREES(h,prop)
%

old_units = get(h, 'AngleUnits');
set(h, 'AngleUnits', 'degrees');
try
  val = h.(prop);
catch
  set(h, 'AngleUnits', old_units);  
  error('getradians:InvalidProperty', 'Invalid property');
end
set(h, 'AngleUnits', old_units);