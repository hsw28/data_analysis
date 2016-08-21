function schema
%SCHEMA for fkGraphics package
%this file contains some type definitions used in several classes

%define the package
schema.package('fkGraphics');

%type used to flag whether an object is clean (i.e. up to date), invalid
%(i.e should be updated) or inconsistent (cannot be updated due to some
%condition)
if( isempty(findtype('DirtyEnum')) )
  schema.EnumType('DirtyEnum',{'clean','invalid','inconsistent'});
end

%type used to set clipping method for angle data in polar axes
if isempty(findtype('AngleClipType'))
  schema.EnumType('AngleClipType',{'nan','clip'});
end

%type used to set clipping method for radius data in polar axes
if isempty(findtype('RadiusClipType'))
  schema.EnumType('RadiusClipType',{'nan','zero','clip'});
end

%type used to set cursor style
if isempty(findtype('CursorStyleType'))
  schema.EnumType('CursorStyleType',{'horizontal','vertical','cross'});
end

%types used to set x and y position of cursor labels
if isempty(findtype('LabelPosType'))
  schema.EnumType('LabelPosType', {'axes','cursor','center'});
end

if isempty(findtype('TextPosXType'))
  schema.EnumType('TextPosXType', {'XW','W','CW','C','CE','E','XE'});
end
if isempty(findtype('TextPosYType'))
  schema.EnumType('TextPosYType', {'XN','N','CN','C','CS','S','XS'});
end

if isempty(findtype('LabelShowModeType'))
  schema.EnumType('LabelShowModeType',{'show','hide','drag','nodrag'});
end

if isempty(findtype('AngleUnitsType'))
  schema.EnumType('AngleUnitsType',{'radians','degrees'});
end
  