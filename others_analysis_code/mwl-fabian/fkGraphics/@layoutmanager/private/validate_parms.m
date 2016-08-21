function parms = validate_parms(parms, valid_parms, varargin)

if mod(numel(varargin),2)
  error('layoutmanager:validate_parms:invalidParameters', 'Invalid parameter(s)')
end

p = lower(varargin(1:2:end));
v = varargin(2:2:end); %#ok

if ~all( ismember( p, valid_parms ) )
  error('layoutmanager:set:invalidParameters', 'Invalid parameter(s)')
end

[nrows, ncols] = size(parms.childmatrix);

for k=1:numel(p)
  
  if strcmp(p{k}, 'width')
    if isscalar(v{k})
      v{k} = ones(1,ncols).*v{k};
    elseif ~isnumeric(v{k}) || numel(v{k})~=ncols
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for width' p{k}] )
    else
      v{k} = v{k}(:)';
    end
  elseif strcmp(p{k}, 'height')
    if isscalar(v{k})
      v{k} = ones(nrows,1).*v{k};
    elseif ~isnumeric(v{k}) || numel(v{k})~=nrows
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    else
      v{k}=v{k}(:);
    end
  elseif strcmp(p{k}, 'z')
    if ~isnumeric(v{k}) || ~isscalar(v{k}) || v{k}<1
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    end
  elseif any(strcmp(p{k}, {'xoffset', 'xspacing', 'yoffset', 'yspacing'} ))
    if ~isnumeric(v{k}) || ~isscalar(v{k})
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    end
  elseif strcmp(p{k}, 'fcn')
    if ~isa(v{k}, 'function_handle')
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    end
  elseif strcmp(p{k}, 'argin')
    if ~iscell(v{k})
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    end
  elseif strcmp(p{k}, 'units')
    if ~ismember(v{k}, {'inches', 'centimeters', 'points', 'pixels', ...
                        'characters'})
      error('layoutmanager:validate_parms:invalidValue', ['Invalid value for ' p{k}])
    end
  end
  
  parms.(p{k}) = v{k};
  
end
