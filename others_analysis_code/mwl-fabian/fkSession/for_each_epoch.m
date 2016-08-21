function out = for_each_epoch( rootdir, func, varargin )
%FOR_EACH_EPOCH execute function for each epoch
%
%  result=FOR_EACH_EPOCH(rootdir,fcn) executes the specified function for
%  each epoch defined in rootdir/epochs/epochs.def. The signature of the
%  function is: result=fcn(epoch_info, ...), where epoch_info is a
%  structure with the name and start and end times of the epoch. The
%  output is a cell array with the results of the function for each
%  epoch.
%

  
if nargin<2
  return
end

if ~isa(func, 'function_handle') || nargin(func)<(1 + numel(varargin)) || ...
      nargout(func)<1
  error('for_each_epoch:invalidArguments', 'Not a function handle, or incorrect number of input/output arguments')
end

%load epoch definition file
if ~exist(fullfile(rootdir, 'epochs', 'epochs.def'), 'file')
    error('for_each_epoch:invalidArguments', 'No epochs.def file found')
else
    f = mwlopen(fullfile(rootdir, 'epochs', 'epochs.def'));
    epochs = load(f);
end

%for each epoch...
n_epochs = numel(epochs.ep_name); 
out = cell( n_epochs, 1);
for k = 1:n_epochs
  out{k} = func( struct( 'name', epochs.ep_name{k}, 'start_time', ...
                         epochs.ep_start(k), 'end_time', epochs.ep_end(k) ...
                         ), varargin{:} );
end
