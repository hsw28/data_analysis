function opt = mkcontmovopt(varargin)

p = inputParser;
p.addParamValue('cdat',[],@isstruct);
p.addParamValue('framerate',10,@isreal);
p.addParamValue('timecompression',1,@isreal);
p.addParamValue('timewin',[],@isreal);
p.addParamValue('dispfun',@easycontdisp,@(x) isa(x,'function_handle'));
p.addParamValue('mkavi',true,@islogical);
p.addParamValue('concatavi',false,@islogical); % Not implemented yet
p.parse(varargin{:});

opt = p.results;