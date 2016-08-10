function opt_struct = do_ripple_analysis_arg(varargin)

p = inputParser;

p.addOptional('import',true,@islogical);
p.addOptional('ripplefilt',true,@islogical);
p.addOptional('makesmooth',true,@islogical);
p.addOptional('makenorm',true,@islogical);
p.addOptional('makeslope',true,@islogical);
p.addOptional('makesmoothslope',true,@islogical);
p.addOptional('drawmov',true,@islogical);
p.addOptional('makeavi',true,@islogical);
p.addOptional('chanmap',[],@(x)not(isempty(x)));

opt_struct = p.Results;