function val=getradians(h,prop)
%GETRADIANS helper function
%
%  val=GETRADIANS(h,prop)
%

old_units = get(h, 'AngleUnits');
set(h, 'AngleUnits', 'radians');
try
  val = h.(prop);
catch
  set(h, 'AngleUnits', old_units);  
  error('getradians:InvalidProperty', 'Invalid property');
end
set(h, 'AngleUnits', old_units);