function result = applyfcn( fcn, argin, varargin )
%APPLYFCN apply function to cell array or all fields of structure
%
%  Syntax
%
%      result = applyfcn( fcn, argin, A, B, ... )
%
%  Description
%
%    Applies a function to all cells in a set of cell arrays or all
%    fields in a set of structs. The function fcn is called repetitively
%    for each cell or field and should have the following signature:
%      output = fcn( A_cell_n, B_cell_n, ..., argin1, argin2, ...)
%      output = fcn( A_field_n, B_field_n, ..., argin1, argin2, ...)
%    Thus all of the cell arrays should have the same dimensions and
%    size, likewise, all structs should have the same fields.

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<3
  help(mfilename)
  return
end
  
%default function is numel
if isempty(fcn)
    fcn = @numel;
elseif ~isa(fcn, 'function_handle')
    error('fkUtilities:applyfcn:invalidFunction', 'Not a valid function handle')
end

if isempty(argin)
    argin={};
elseif ~iscell(argin)
    argin = {argin};
end

n = numel(varargin);

%check target objects
obj_type = class(varargin{1});
obj_ndims = ndims(varargin{1});
obj_size = size(varargin{1});
obj_n = numel(varargin{1});
if strcmp(obj_type, 'cell') || strcmp(obj_type, 'struct')
    for k=2:n
        if ~isa(varargin{k}, obj_type) || ndims(varargin{k})~=obj_ndims || ~all(size(varargin{k})==obj_size)
            %error('Target objects do not have same size or type')
            %target objects are dissimilar, so treat them as single inputs
            obj_type = 'other';
        end
    end
end

if strcmp(obj_type, 'cell')
    
    result = cell(obj_size);
    obj = cat( obj_ndims+1, varargin{:} );
    obj = reshape( obj, obj_n, n);
    for k=1:obj_n
        if nargout>0
            try
                result{k} = fcn( obj{k,:}, argin{:} );
            catch
                result{k} = NaN;
            end
        else
            fcn( obj{k,:}, argin{:} );
        end
    end
    
elseif strcmp(obj_type, 'struct')
    
    %check structures
    fn = fieldnames( varargin{1} );
    obj = struct2cell( varargin{1} );
    for k=2:n
        fn_tmp = fieldnames( varargin{k} );
        if numel(fn)~=numel(fn_tmp) || ~all( strcmp( fn ,fn_tmp ) )
            error('fkUtilities:applyfcn:dissimilarStructs', 'Structures have different fields')
        end
        obj(:,k) = struct2cell(varargin{k});
    end
    
    result = varargin{1};
    
    for k=1:numel(fn)
        if nargout>0
            try
                result.(fn{k}) = fcn( obj{k,:}, argin{:} );
            catch
                result.(fn{k}) = NaN;
            end
        else
            fcn( obj{k,:}, argin{:} );
        end
    end
    
else
    if nargout>0
        try
            result = fcn( varargin{:}, argin{:} );
        catch
            result = NaN;
        end
    else
        fcn( varargin{:}, argin{:} );
    end
end
