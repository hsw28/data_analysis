function [argstruct, otherargs, remainder] =parseArgs(args,argstruct)
%PARSEARGS Helper function for parsing varargin. 
%
%  options=PARSEARGS(options,option_struct) parse the arguments in the cell
%  array options. option_struct is a structure which fields define the
%  valid parameter names and default values. An error is issued if an
%  unknown parameter name is encountered. Any initial unnamed parameters
%  will be skipped.
%
%  [options,other]=PARSEARGS(options,option_struct) Any unnamed
%  parameters are returned in the other cell array.
%
%  [options,other,remainder]=PARSEARGS(options,option_struct) Any unknown
%  named parameters will be returned in remainder and no error is
%  generated.
%

%  Copyright 2007-2008 Fabian Kloosterman

remainder = {};
otherargs = {};

if isempty(args)
  return
end

valid_args = fieldnames( argstruct );
valid_args_size = cellfun('prodofsize',valid_args);


%---------------Get "numeric" arguments
num_other = find( cellfun('isclass',args,'char'), 1, 'first' ) - 1;
if isempty(num_other)
  otherargs=args;
  return
elseif num_other>0
  otherargs=args(1:num_other);
end

for k=(num_other+1):2:numel(args)
  
  if ~ischar(args{k})
    error('parseArgs:invalidArgument', 'Expected a named argument')
  end
  
  %match parameter to list of valid arguments
  idx = find(strncmpi( args{k}, valid_args, numel(args{k}) ));
  
  if isempty(idx)
    %no match
    if nargout>2
      remainder(end+(1:2)) = args(k+(0:1));
    else
      error('parseArgs:invalidArgument', ['Unknown named parameter: ' args{k}])
    end
  elseif numel(idx)>1
    %multiple matches, select shortest
    [midx,midx] = min(valid_args_size(idx)); %#ok
    argstruct.(valid_args{idx(midx)}) = args{k+1};
  else
    %single match
    argstruct.(valid_args{idx}) = args{k+1};
  end
  
end
