function [parms, changed_parms] = validate_parms(parms, valid_parms, varargin)

if mod(numel(varargin),2)
  error('slider:validate_parms:invalidParameters', 'Invalid parameter(s)')
end

p = lower(varargin(1:2:end));
v = varargin(2:2:end); %#ok

if ~all( ismember( p, valid_parms ) )
  error('slider:validate_parms:invalidParameters', 'Invalid parameter(s)')
end


for k=1:numel(p)

  switch p{k}
    
   case 'limits'
    if ~isnumeric(v{k}) || numel(v{k})~=2 || v{k}(1)>=v{k}(2)
      error('slider:validate_parms:invalidValue', 'Invalid limits')
    end
    v{k} = v{k}(:)';
   case 'center'
    if ~isnumeric(v{k}) || ~isscalar(v{k})
      error('slider:validate_parms:invalidValue', 'Invalid center')
    end
   case 'windowsize'
    if ~isnumeric(v{k}) || ~isscalar(v{k}) || v{k}<=0
      error('slider:validate_parms:invalidValue', 'Invalid window size')
    end
   case 'updatemode'
    if ~ischar(v{k}) || ~ismember(v{k}, {'delayed', 'live'})
      error('slider:validate_parms:invalidValue', 'Invalid update mode')
    end
   case 'displaymode'
    if ~ischar(v{k}) || ~ismember(v{k}, {'strict', '+50%', 'window size'})
      error('slider:validate_parms:invalidValue', 'Invalid display mode')
    end
   case 'color'
    if ~isnumeric(v{k}) || numel(v{k})~=3
      error('slider:validate_parms:invalidValue', 'Invalid color')
    end
    v{k} = v{k}(:)';
   case 'currentmarker'
    if ~ischar(v{k}) || (~strcmp(v{k}, 'none') && ~ismember(v{k}, fieldnames(parms.markers)))
      error('slider:validate_parms:invalidValue', 'Invalid current marker')
    end      
  end
    
  parms.(p{k}) = v{k};
  
end

changed_parms = unique(p);

parms.windowsize = min( parms.windowsize, diff(parms.limits) );
parms.center = max( min( parms.center, parms.limits(2) - 0.5.*parms.windowsize ...
                         ), parms.limits(1)+0.5.*parms.windowsize );
