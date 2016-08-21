function s = struct2str( st )
%STRUCT2STR convert struct to string representation
%
%  s=STRUCT2STR(struct) convert a structure to a string, such that
%  eval(s) will return the original structure. This function can handle
%  2d cell arrays, 2d numeric and logical arrays, character strings (not
%  arrays) and structures.
%
%  See also: MAT2STR, CELL2STR
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

if ~isstruct(st)
  error('struct2str:invalidArgument', 'Not a struct')
end
  
if numel(st)>1
  error('struct2str:ScalarInput', ['Only scalar structs ' ...
                      'supported'])
end


fn = fieldnames( st );

%handle special cases
if isempty( st )
  if isempty(fn)
    s = 'struct([])';
  else
    s = 'struct(';
    for k=1:numel(fn)
      s = [s '''' fn{k} ''',{}'];
      if k<numel(fn)
        s = [s ','];
      end
    end
    s = [s ')'];
  end
  return    
end


%convert all fields
s = 'struct(';

fn = fieldnames( st );

for k=1:numel(fn)
  s = [s '''' fn{k} ''','];
  if isnumeric(st.(fn{k})) || islogical(st.(fn{k}))
    s = [s mat2str(st.(fn{k}))];
  elseif iscell(st.(fn{k}))
    s = [s '{' cell2str(st.(fn{k})) '}'];
  elseif ischar(st.(fn{k})) && size(st.(fn{k}),1)==1
    s = [s '''' st.(fn{k}) '''' ];
  elseif isstruct(st.(fn{k}))
    s = [s struct2str(st.(fn{k}))];
  else %i.e. >1-D char arrays, function handles, objects, etc
      error('struct2str:invalidElement', ['Unable to convert ' ...
                          'object of class ' class( st.(fn{k}) ) ' and size [' ...
                          num2str( size(  st.(fn{k}) ) ) '].'])
  end  
  if k<numel(fn)
    s=[s ','];
  end
end

s = [s ')'];
