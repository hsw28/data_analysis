function setdegrees(h,prop,val)
%SETDEGREES helper function
%
%  SETDEGREES(h,prop,val)
%

old_units = get(h, 'AngleUnits');
set(h, 'AngleUnits', 'degrees');
try
  h.(prop) = val;
catch
  set(h, 'AngleUnits', old_units);
  error('setradians:invalidProperty', 'Unable to set property')
end
set(h, 'AngleUnits', old_units);