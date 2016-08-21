function b=hasinterface(h,ii)
%HASINTERFACE check if object supports interface
%
%  b=HASINTERFACE(h,interface) where interface is a structure with
%  'properties' and 'methods' fields, each of which is a cell array
%  of strings. The functions return true if the object has all
%  properties and methods as defined by the interface
%

%  Copyright 2008-2008 Fabian Kloosterman

%check arguments
if nargin<2 || ~ishandle(h) || ~isstruct(ii) || ...
      ~all(ismember({'properties','methods'},fieldnames(ii))) || ...
      ~iscellstr(ii.properties) || ~iscellstr(ii.methods)
  error('hasinterface:invalidArguments', ['Invalid handle and/or interface ' ...
                      'structure']);
end

%convert handle
h = handle(h);

b = true;

%test for properties
for k=1:numel(ii.properties)
  
  b = b && isprop(h,ii.properties{k});
  
end

%test for methods
for k=1:numel(ii.methods)
  
  b = b && ismethod(h,ii.methods{k});
  
end
