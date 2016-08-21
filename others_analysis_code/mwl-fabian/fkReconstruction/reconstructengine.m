function E = reconstructengine(spikes, behavior, varargin)
%RECONSTRUCTENGINE create a position reconstruction engine
%
%  e=RECONSTRUCTENGINE(spikes, behavior) returns a reconstruction engine
%  and initialize it with a cell array of spike time vectors and a
%  behavior structure. The behavior structure should contain the fields
%  'timestamp' and 'variables' and 'varnames'.
%
%  A reconstruction engine has the following inputs:
%   viewport - sorted and non-overlapping list of time segments for which
%              to do position reconstruction. (results for all viewports
%              are concatenated).
%   spikes - cell array of spike time vectors to use for reconstruction
%            (by default uses the defaultspikes input)
%   defaultspikes - cell array of spike time vector to use for tuning map
%                   construction.
%   behavior - structure of behavioral timestamps, variables and names.
%
%  A reconstruction engine contains the following engines:
%   bin - for binning the time segments
%   rate - for counting the number of spikes in each bin
%   spikes - for selecting the source input for spikes
%   grid - maintains sampling grid for behavioral variables
%   basis - creates tuning maps
%   reconstruct - bayesian reconstruction
%   reshape_reconstruct - reshapes reconstruction matrix
%   reshape_basis - reshapes tuning maps
%   reshape_occupancy - reshapes occupancy map
%   threshold - optionally thresholds position reconstruction matrix
%   randomize - optionally randomizes spike counts, before reconstruction
%
%  A reconstruction engine has the following outputs:
%   bins - time bins used for position reconstruction
%   spikecount - spike count matrix
%   estimate - position reconstruction matrix
%   tuningmaps - tuning maps
%   occupancy - occupancy map
%   spikes - same as default spikes input
%   behavior - same as behavior input
%   grid - sampling grid of behavioral variables
%   nbins - for each viewport, the number of bins
%


%spikes: cell array of spike trains
%behavior: struct with three fields: time, variables, varnames

binengine = fcnengine( 'slots_in', struct('viewport', [], 'overlap', 0, 'binsize', 0.025), ...
                       'slots_out', {'bins', 'nbins'}, ...
                       'positional_slots', 1, ...
                       'fcn', @seg2bin, ...
                       'name', 'bin', ...
                       'output_caching', 1 );

rateengine = fcnengine( 'slots_in', struct('spikes', [], 'bins', [], 'method', 'count'), ...
                        'slots_out', {'spikecount'}, ...
                        'positional_slots', [1 2], ...
                        'output_caching', 0, ...
                        'name', 'rate', ...
                        'fcn', @event2bin, ...
                        'types_in', {NaN,NaN,'char'});

                          
cellselectrate = fcnengine( 'slots_in', struct('matrix', [], 'selection', []), ...
                            'slots_out', {'matrix'}, ...
                            'types_in', {NaN, NaN}, ...
                            'name', 'cellselectrate', ...
                            'output_caching', 0, ...
                            'positional_slots', [1 2], ...
                            'fcn', @cellselectratefcn);
                          
                          
spikesdefault = fcnengine( 'slots_in', struct('spikes', [], 'defaultspikes', []), ...
                           'slots_out', {'spikes'}, ...
                           'positional_slots', [1 2], ...
                           'fcn', @default, ...
                           'name', 'spikes' );


nvar = size(behavior.variables,2);
options = struct();
types = struct();
for k=1:nvar
  options.(['grid_' num2str(k)]) = ['linspace(' num2str(min(behavior.variables(:,k))) ...
                      ',' num2str(max(behavior.variables(:,k))) ',10)'];
  options.(['name_' num2str(k)]) = behavior.varnames{k};
  types.(['grid_' num2str(k)]) = 'char';
  types.(['name_' num2str(k)]) = 'char';
end

gridengine = fcnengine( 'slots_in', options, ...
                        'slots_out', {'grid', 'ndims', 'size'}, ...
                        'name', 'grid', ...
                        'types_in', types, ...
                        'output_caching', 1, ...
                        'fcn', @create_grid);

spikebehavengine = fcnengine( 'slots_in', struct('spikes', [], ...
                                                 'behavior', [], ...
                                                 'vartypes', [], ...
                                                 'interp', 'linear'), ...
                              'slots_out', {'spikebehavior'}, ...
                              'types_in', {NaN, NaN, 'cellstr', 'char'}, ...
                              'name', 'spikebehav', ...
                              'output_caching', 1, ...
                              'fcn', @spikebehav, ...
                              'positional_slots', [1 2]);

basisengine = fcnengine( 'slots_in', struct('spikes', [], ...
                                            'behavior', [], ...
                                            'grid', [], ...
                                            'smooth', [], ...
                                            'segments', [], ...
                                            'samplefreq', 30, ...
                                            'normalization', 'none'), ...
                         'slots_out', {'tuningmaps', 'occupancy'}, ...
                         'types_in', {NaN, NaN, NaN, 'double', 'double', 'double', 'char'}, ...
                         'name', 'basis', ...
                         'output_caching', 1, ...
                         'fcn', @basisfcn, ...
                         'positional_slots', [1 2]);
                         
cellselectbasis = fcnengine( 'slots_in', struct('tuningmaps', [], 'selection', []), ...
                              'slots_out', {'tuningmaps'}, ...
                              'types_in', {NaN, NaN}, ...
                              'name', 'cellselectbasis', ...
                              'output_caching', 0, ...
                              'positional_slots', [1 2], ...
                              'fcn', @cellselectbasisfcn);
                          
reconstruct = fcnengine( 'slots_in', struct('tuningmaps', [], ...
                                            'spikecount', [], ...
                                            'prior', [], ...
                                            'bins', [], ...
                                            'normalization', 'sum', ...
                                            'useprior', 0, ...
                                            'alpha', 1, ...
                                            'baseline', 0.01, ...
                                            'function', 'bayesian'), ...
                         'slots_out', {'estimate'}, ...
                         'types_in', {NaN,NaN,NaN,NaN,'char','logical','double','double', 'char'},...
                         'name','reconstruct',...
                         'output_caching', 0, ...
                         'positional_slots', [1 2],...
                         'fcn', @reconstructfcn);

%reshapereconstruct = reshape_engine( 'reshape_reconstruct' );

%reshapebasis = reshape_engine( 'reshape_basis' );

%reshapeoccupancy = reshape_engine( 'reshape_occupancy' );

threshold = fcnengine( 'slots_in', struct('matrix',[],'threshold',0,'mode',0,'binarize',0),...
                       'slots_out',{'matrix'},...
                       'name', 'threshold',...
                       'output_caching', 1, ...
                       'positional_slots', 1, ...
                       'fcn', @dothreshold, ...
                       'types_in', {NaN, 'double', 'logical', 'logical'});

randomizerate = randengine( 'randomizerate', 'output_caching', 1 );
randomizerate.enable = 0;

randomizebasis = randengine( 'randomizebasis', 'output_caching', 0);
randomizebasis.enable = 0;

connections = {
    'in', 1, 'bin', 1; ...
    'in', 2, 'spikes', 1; ...
    'in', 3, 'spikes', 2; ...
    'spikes', 1, 'rate', 1; ...
    'bin', 1, 'rate', 2; ...
    'bin', 1, 'out', 1; ...
    'randomizerate', 1, 'out', 2; ...
    'in', 3, 'spikebehav', 1; ...
    'in', 4, 'spikebehav', 2; ...
    'spikebehav', 1, 'basis', 1; ...
    'in', 4, 'basis', 2; ...
    'grid', 1, 'basis', 3; ...
    'in', 5, 'cellselectbasis', 2; ...
    'in', 5, 'cellselectrate', 2; ...
    'basis', 1, 'cellselectbasis', 1; ...
    'cellselectbasis', 1, 'randomizebasis', 1; ...
    'randomizebasis', 1, 'reconstruct', 1; ...
    'rate', 1, 'cellselectrate', 1; ...
    'cellselectrate', 1, 'randomizerate', 1; ...
    'randomizerate', 1, 'reconstruct', 2; ...
    'basis', 2, 'reconstruct', 3; ...
    'bin', 1, 'reconstruct', 4; ...
    'reconstruct', 1, 'threshold', 1; ...
    'threshold', 1, 'out', 3; ...
    'cellselectbasis', 1, 'out', 4; ...
    'basis', 2, 'out', 5; ...
    'in', 3, 'out', 6; ...
    'in', 4, 'out', 7; ...
    'grid', 1, 'out', 8; ...
    'bin', 2, 'out', 9 ...
    };


engines = {binengine, rateengine, spikesdefault, gridengine, basisengine, ...
           reconstruct, threshold, randomizerate, spikebehavengine, randomizebasis, ...
           cellselectbasis, cellselectrate};

E = compoundengine('engines', engines, ...
                   'connections', connections, ...
                   'slots_in', struct('viewport', [], 'spikes', [], ...
                                      'defaultspikes', { spikes }, 'behavior', ...
                                      { behavior }, 'cellselection', []), ...
                   'slots_out', {'bins', 'spikecount', 'estimate', ...
                    'tuningmaps', 'occupancy', 'spikes', 'behavior', ...
                    'grid', 'nbins'}, ...
                   'name', 'engine' );


if mod( numel(varargin), 2 )==1
  return
end

for k=1:2:numel(varargin)
  if ~ischar(varargin{k}) || ~isvector(varargin{k})
    continue
  end
  fprintf(1,['trying to set engine.' varargin{k} ' ... ']);  
  try
    eval(['E.' varargin{k} '=varargin{' num2str(k+1) '};' ]);
    fprintf(1,'ok\n');
  catch
    fprintf(1,'failed\n');    
  end
end

function out = default(A,B)

if isempty(A)
  out = B;
else
  out = A;
end

function m = dothreshold(m, varargin)
%threshold / mode / binarize

args = parseArgs( varargin, struct('threshold',0, 'mode', 0, 'binarize',0) );


if args.threshold>0
  m( m<args.threshold ) = 0;
end

if args.mode
  %find max in a time slice
  sz = size(m);
  [mval, idx] = max( reshape( m, prod(sz(1:end-1)), sz(end) ) );
  m = zeros(sz);
  m(sub2ind([prod(sz(1:end-1)), sz(end)], idx, 1:sz(end))) = mval;
end

if args.binarize
  m(m~=0)=1;
end


function [g, nd, sz] = create_grid(varargin)

p = varargin(1:2:end);
v = varargin(2:2:end);

g = {};

for k=1:numel(p)
  
  r = regexp( p{k}, '^(?<option>[a-zA-Z]+)_(?<n>[0-9]+)', 'names');
  
  r.n = str2double(r.n);
  
  if ~isempty(r)
    
    switch r.option
     case 'grid'
      if ischar(v{k})
        g{r.n} = {'l', eval( v{k} ), ''};
      else
        g{r.n} = {'l', v{k}, ''};        
      end
     case 'name'
      g{r.n}{3} = v{k};
    end
  end

end

if any( cellfun('isempty', g) )
  error('create_grid:dimMismatch', 'Dimension mismatch')
end

g = fkgrid( g{:} );
nd = ndims(g);
sz = size(g);


% $$$ function [spikemaps, occupancy] = basisfcn( spikes, behavior, grid, varargin )
% $$$ 
% $$$ args = struct( 'normalization', 'none', ...
% $$$                'reciprocal', 0, ...
% $$$                'smooth', 0, ...
% $$$                'smooth_sd', 0, ...
% $$$                'segments', [] );
% $$$ 
% $$$ args = parseArgs( varargin, args );
% $$$ 
% $$$ %find variables and spikes in time windows
% $$$ if ~isempty(args.segments)
% $$$   
% $$$   behav_filter = inseg( behavior.time, args.segments );
% $$$   
% $$$   %for cells find spikes in time windows
% $$$   spikes = applyfcn( @(t) t(inseg( t, args.segemnts )), [], spikes ...
% $$$                      );
% $$$ else
% $$$   
% $$$   behav_filter = true(numel(behavior.time),1);
% $$$ 
% $$$ end
% $$$ 
% $$$ %find behavior for cells
% $$$ for c = 1:numel(spikes)
% $$$   for v = 1:ndims(grid)
% $$$     switch grid(v).type
% $$$      case 'linear'
% $$$       cell_behavior{c}(:,v) = interp1( behavior.time, ...
% $$$                                        behavior.variables(:,v), spikes{c}, 'nearest' ); %#ok
% $$$      case 'circular'
% $$$       cell_behavior{c}(:,v) = interp1( behavior.time, unwrap( behavior.variables(:,v) ), spikes{c}, 'nearest' );
% $$$     end
% $$$   end
% $$$ end
% $$$ 
% $$$ %construct occupancy map, spike maps and rate maps
% $$$ occupancy = map( grid, behavior.variables(behav_filter,1:ndims(grid)) );
% $$$ if args.smooth
% $$$   dx = applyfcn( @(obj) mean(diff(obj)), [], centers(grid) );
% $$$   if iscell(dx)
% $$$     dx = cell2mat( dx );
% $$$   end
% $$$   dx(isnan(dx)|isinf(dx))=1;
% $$$   occupancy = smoothn( occupancy, args.smooth_sd, dx,1 ,1 );
% $$$ end
% $$$ occupancy = occupancy(:);
% $$$ 
% $$$ for c = 1:numel(spikes)
% $$$   tmp  = map( grid, cell_behavior{c}, 'Default', 0 );
% $$$   if args.smooth
% $$$     tmp = smoothn( tmp, args.smooth_sd, dx, 1, 1 );
% $$$   end
% $$$   spikemaps(:,c) = 30 * tmp(:)./occupancy;
% $$$ end
% $$$ 
% $$$ %remove NaNs
% $$$ spikemaps(isnan(spikemaps))=0;
% $$$ 
% $$$ % normalize
% $$$ spikemaps = normalize(spikemaps, 1, args.normalization);
% $$$ 
% $$$ 
% $$$ % reciprocal
% $$$ if args.reciprocal
% $$$   spikemaps = pinv(spikemaps)';
% $$$ end



% $$$ function E = reconstructfcn( P, A, prior, bins, varargin )
% $$$ 
% $$$ options = struct('prior', 0, 'normalization', 'sum', 'alpha', 1);
% $$$ 
% $$$ options = parseArgs( varargin, options);
% $$$ 
% $$$ if isempty(bins)
% $$$   bins = ones( 1, size(A,2) );
% $$$ elseif isscalar(bins)
% $$$   bins = bins.*ones(1, size(A,2) );
% $$$ elseif isvector(bins) && numel(bins)==size(A,2)
% $$$   bins = bins(:)';
% $$$ elseif size(bins,1)==size(A,2) && size(bins,2)==2
% $$$   bins = diff( bins, [], 2)';
% $$$ else
% $$$   error('reconstructfcn:invalidArguments', 'Invalid bins')
% $$$ end
% $$$ 
% $$$ P=P+eps; %add very small value to make algorithm robust
% $$$ 
% $$$ if options.alpha~=1
% $$$   P = P.*options.alpha;
% $$$ end
% $$$ 
% $$$ E = exp( sum( P, 2 ) * -bins );
% $$$ E = E.* bayesian_helper( P, A ); %prod( P.^A )
% $$$ 
% $$$ if (options.prior)
% $$$   E = E .* repmat( prior, [ 1 size(E, 2) ] );
% $$$ end
% $$$ 
% $$$ E = normalize( E, 1, options.normalization,1 );

function E = reconstructfcn( P, A, varargin )

options = struct('useprior', 0, 'prior', [],'function','bayesian');
[options, other, remainder] = parseArgs(varargin,options); %#ok

if ~options.useprior
  options.prior = [];
end

switch options.function
 case 'basis'
  E = reconstruct_basis( P, A, remainder{:}, 'prior', options.prior );
 case 'bayesian'
  E = reconstruct_bayesian_poisson( P, A, remainder{:}, 'prior', options.prior);
 case 'extended'
  E = reconstruct_bayesian_extended( P, A, remainder{:} );
 otherwise
  error('reconstructfcn:invalidFunction', 'Invalid reconstruction function')
end




function result = spikebehav(spikes, behavior, varargin)

result = var2spike( spikes, behavior.time, behavior.variables, ...
                            varargin{:}, 'addtime', 1 );

function [rm, om] = basisfcn( spike_vars, behav_vars, varargin )

options = struct( 'segments', [], 'grid', [], 'smooth', [], 'normalization', ...
                  'none');
[options, other, remainder] = parseArgs(varargin,options); %#ok

%add time to grid
g = options.grid + fkgrid( [-Inf Inf] );

%no smooth in time
if ~isempty(options.smooth)
  options.smooth = [options.smooth 0];
end

%filtering in time
if ~isempty(options.segments)
  f = cat(2, cell(1,ndims(options.grid)), ...
          {segmentfilter(options.segments)});
else
  f = [];
end

[rm, g, om] = ratemap( spike_vars, [behav_vars.variables behav_vars.time], ...
                       remainder{:}, 'filters', f, 'grid', g, ...
                       'smooth', options.smooth ); %#ok

rm = reshape( rm, [size(options.grid) numel(spike_vars)] );

rm = normalize( rm, 1, options.normalization, 1 );

%remove NaNs
rm(isnan(rm))=0;


function m = cellselectbasisfcn(m,s)

if ~isempty(s)

    nd = ndims(m);
    idx = repmat( {':'}, [1 nd] );
    idx{nd} = s;
    m = m(idx{:});
    
end


function m = cellselectratefcn(m,s)

if ~isempty(s)
    
    m = m(s,:);
    
end
