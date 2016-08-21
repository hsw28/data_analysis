function setradians(h,prop,val)
%SETRADIANS helper function
%
%  SETRADIANS(h,prop,val)
%

old_units = get(h, 'AngleUnits');
set(h, 'AngleUnits', 'radians');
try
  h.(prop) = val;
catch
  set(h, 'AngleUnits', old_units);
  error('setradians:invalidProperty', 'Unable to set property')
end
set(h, 'AngleUnits', old_units);