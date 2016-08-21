function R = detect_replay_new( varargin )
%DETECT_REPLAY_NEW
%

%---------------------
%---CHECK ARGUMENTS---
%---------------------

run_options = struct( 'nshufflepseudo', 0, ... %number of pseudo shuffles
                      'nshuffleclperm', 0, ... %number of cluster permutation shuffles
                      'nshufflecycle', 0, ... %number of randcycle shuffles
                      'binomialtest', 1, ... %0/1 est chance of significance after every 50 shuffles
                      'binomialsuccess', 0.01, ... %probability of finding a shuffle>actual score
                      'binomialpvalue', 0.01 ); % maximum probability below which an event is
                                              % regarded non-significant and no more shuffle are performed

options = struct( 'posgrid', [], ... %position grid (char)
                  'velgrid', [], ... %velocity grid (char)
                  'timebin', 0.02, ... %time bin size for reconstruction
                  'overlap', 0, ...
                  'velsmooth_sd', 0.25 ); %smoothing stdev for velocity
                                          %calculation

smooth_options = struct('smoothkernel', 'box', ... %type of smoothing kernel ('box', 'gauss', 'none')
                        'kernelwidth', [0 0 0], ... %smoothing kernel width for position, velocity and time
                        'smoothcorrect', 1, ... %correct for smoothing at edges
                        'normalize', 0 );

radon_options = struct('method', 'sum', ... %radon transform method: 'sum','product','logsum'
                       'valid', 0, ... %yes/no compute valid lines only (those that span full width/height of window)
                       'interp', 'nearest', ... %interpolation: 'linear','nearest'
                       'rho_x', 0, ... %0/1
                       'pad', 1, ... %yes/no padding of lines that do not span full width of window
                       'padmethod', 'median'); %method of padding 'mean' of columns or 'random' draw from columns


if nargin<1
  help(mfilename)
  return
elseif isstruct(varargin{1}) && ismember( 'info', fieldnames( varargin{1} ) )
  R = varargin{1};
  
  [run_options, other, remainder] = parseArgs( varargin(2:end), run_options ); %#ok
  
else
  
  [options, other, remainder] = parseArgs( varargin, options );
  [smooth_options, tmp, remainder] = parseArgs( remainder, smooth_options );
  [radon_options, tmp, remainder] = parseArgs( remainder, radon_options );  
  [run_options, tmp, remainder] = parseArgs( remainder, run_options );
  
  radon_options.dx=1;
  radon_options.dy=1;
  radon_options.constraint='row';
  
  %check for at least 4 non-option arguments
  if isempty(other) || numel(other)~=4
    help(mfilename)
    return
  end
  
  %create behavior struct
  behavior = struct( 'time', other{2}, ...
                     'variables', [other{3}(:) smoothn( ...
                         gradient( other{3}(:), 1./30 ), ...
                         options.velsmooth_sd, 1./30 )], ...
                     'varnames', {{'position', 'velocity'}} );
  
  R.info = options;
  R.info.date = datestr(now);
  R.info.spikes =  other{1};
  R.info.behavior = behavior;
  R.info.segments = other{4};
  R.info.radon = radon_options;
  R.info.smooth = smooth_options;
  
  %round segment times to nearest multiple of effective bin size
  R.info.segments = [floorto(R.info.segments(:,1), (1-R.info.overlap).*R.info.timebin) ceilto(R.info.segments(:,2), (1-R.info.overlap).*R.info.timebin)];
  
  R.info.engine_options = remainder;
  
end


%--------------------
%---INITIALIZATION---
%--------------------

%total number of segments
nseg = size(R.info.segments,1);

%segment lengths in #bins
L = round( (diff(R.info.segments,1,2)-R.info.timebin) ./ ((1-R.info.overlap).*R.info.timebin) + 1 );
%L = round( diff( R.info.segments, 1, 2)./R.info.timebin );
%unique window lengths in #bins of selected segments
[UL] = unique(L) ;

%offset of segments (for use in concatenated matrix)
cumL = cumsum([1;L]);

%position bin size
dpos = mean( diff( eval(R.info.posgrid ) ) );
%# position bins
npos = numel( eval( R.info.posgrid ) ) - 1;

%create engine
posE = reconstructengine( R.info.spikes, R.info.behavior, ...
                          R.info.engine_options{:} );

%set position grid
if ~isempty(R.info.posgrid) && ~strcmp(posE.grid.grid_1, R.info.posgrid)
  posE.grid.grid_1 = R.info.posgrid;
end
%set velocity grid
if ~isempty(R.info.velgrid) && ~strcmp(posE.grid.grid_2, R.info.velgrid)
  posE.grid.grid_2 = R.info.velgrid;
end

%set time bin size
posE.bin.binsize = R.info.timebin;
posE.bin.overlap = R.info.overlap;

%disable randomization
posE.randomizerate.enable=0;
posE.randomizebasis.enable=0;
  
%set engine viewport to include all selected segments
posE.viewport = R.info.segments;

%compute estimate for all selected segments
est = execute_core(posE, {'estimate'});

%permute dimensions: position x time x velocity
est = permute( est, [1 3 2]);
%number of velocity bins
nvel = size( est, 3);

%create vector of sample sizes for smoothing
R.info.smooth.spacing = [dpos (1-R.info.overlap).*R.info.timebin 1];

radonoptions = struct2param(R.info.radon);
smoothoptions = struct2param(R.info.smooth);



%-----------------------------
%---COMPUTE RADON TRANSFORM---
%-----------------------------

if ~isfield(R,'target')
    R.target = struct('success', repmat( {false}, nseg, 1 ) );
end

if nvel>1
  tmp = mat2cell( est, npos, L, nvel );
  [R.target(1:nseg).estimate_vel] = deal( tmp{:} );
end

tmp = mat2cell( sum(est,3), npos, L );
[R.target(1:nseg).estimate] = deal( tmp{:} );

tmp = mat2cell( R.info.segments, ones(nseg,1), 2 );
[R.target(1:nseg).segment] = deal( tmp{:} );


smest = smoothn( est, R.info.smooth.kernelwidth, R.info.smooth.spacing, ...
                 'nanexcl', 1, 'correct', R.info.smooth.smoothcorrect, ...
                 'kernel', R.info.smooth.smoothkernel, 'normalize', R.info.smooth.normalize);
sumsmest = smoothn( sum(est,3), R.info.smooth.kernelwidth, R.info.smooth.spacing, ...
                 'nanexcl', 1, 'correct', R.info.smooth.smoothcorrect, ...
                 'kernel', R.info.smooth.smoothkernel, 'normalize', R.info.smooth.normalize);

for k=1:nseg
  
  %skip if already processed
  if R.target(k).success
    continue
  end  

  R.target(k).nbins = L(k);
  
  %compute radon
  if nvel>1
    for j=1:nvel
      [R.target(k).radon_vel] = padded_radon( smest(:,cumL(k):cumL(k+1)-1,j), radonoptions{:});
    end
  end
  
  [R.target(k).radon, nn, settings] = padded_radon( sumsmest(:,cumL(k):cumL(k+1)-1), radonoptions{:});

  %find radon max
  R.target(k).theta = settings.theta;
  R.target(k).rho = settings.rho;
  
  [R.target(k).radonmax, idx] = max( R.target(k).radon(:) );
  [idx(1) idx(2)] = ind2sub( size(R.target(k).radon), idx );
  
  R.target(k).thetamax = settings.theta( idx(1) );
  R.target(k).rhomax = settings.rho( idx(2) );
   
  R.target(k).line_columns = squeeze( nn(idx(1),idx(2),:) );
  
  R.target(k).score = R.target(k).radonmax ./ L(k);

  if nvel>1  
    R.target(k).radonmax_vel = squeeze( R.target(k).radon_vel( idx(1), idx(2), :))';
    R.target(k).score_vel = R.target(k).radonmax ./ L(k);
    
    %compute projection
    
    for j=1:nvel
      R.target(k).projection_vel(:,j) = padded_projection(smest(:,cumL(k):cumL(k+1)-1,j),...
                                                        R.target(k).thetamax, ...
                                                        R.target(k).rhomax, ...
                                                        radonoptions{:});
    end
  end
  
  R.target(k).projection = padded_projection(sumsmest(:,cumL(k):cumL(k+1)-1),...
                                             R.target(k).thetamax, ...
                                             R.target(k).rhomax, ...
                                             radonoptions{:});
  
  R.target(k).mode_projection_vel = squeeze( max( smest(:,cumL(k):cumL(k+1)-1,:) ));
  R.target(k).mode_projection = max(sumsmest(:,cumL(k):cumL(k+1)-1))';
  
  R.target(k).success=true;
  
end

%-----------------------------
%----PSEUDO EVENT SHUFFLE-----
%-----------------------------

if run_options.nshufflepseudo>0

  if ~isfield(R, 'shufflepseudo')
    R.shufflepseudo = repmat(struct('radonmax',[],'seed', [], 'example',[]), [UL(end),1] );
  end
  
  for j=1:numel(UL)
    
% $$$     if isempty(R.shufflepseudo(UL(j)).example)
% $$$       [dummy dummy R.shufflepseudo(UL(j)).example] = ...
% $$$           replay_shuffle_pseudo( sum( est, 3 ), 1, UL(j), 'binomialtest', 0, radonoptions{:}, smoothoptions{:}); %#ok
% $$$       R.shufflepseudo(UL(j)).example.score = ...
% $$$           R.shufflepseudo(UL(j)).example.radonmax ./ UL(j);
% $$$     end
    
    tic;
    
    [tmp1, tmp2] = replay_shuffle_pseudo( R.target, R.info, run_options.nshufflepseudo, ...
                                         UL(j), 'binomialpvalue', run_options.binomialpvalue, ...
                                         'shufflevalue', R.shufflepseudo(UL(j)).radonmax);
%                                         radonoptions{:}, smoothoptions{:});
    
    
    R.shufflepseudo(UL(j)).radonmax = [R.shufflepseudo(UL(j)).radonmax;tmp1];
    R.shufflepseudo(UL(j)).seed = [R.shufflepseudo(UL(j)).seed;tmp2];
    R.shufflepseudo(UL(j)).score = R.shufflepseudo(UL(j)).radonmax ./ UL(j);
    
    t = toc;
    
    disp(['pseudo ' num2str(j) ' (' num2str(UL(j)) ') ' num2str(t) 's']);
    
  end
  
end


%-----------------------------
%--------CYCLE SHUFFLE--------
%-----------------------------

if run_options.nshufflecycle>0

  if ~isfield(R, 'shufflecycle')
    R.shufflecycle = repmat(struct('radonmax',[],'seed', [], 'example',[]), [nseg,1] );
  end  
  
  for k=1:nseg
    
% $$$     if isempty(R.shufflecycle(k).example)
% $$$       [dummy dummy R.shufflecycle(k).example] = ...
% $$$           replay_shuffle_cycle( sum( est, 3 ), 1, 'binomialtest', 0, radonoptions{:}, smoothoptions{:}); %#ok
% $$$       R.shufflecycle(k).example.score = ...
% $$$           R.shufflecycle(k).example.radonmax ./ L(k);
% $$$     end
    
    tic;
    
    [tmp1, tmp2] = replay_shuffle_cycle( R.target(k), R.info, run_options.nshufflecycle, ...
                                         'binomialpvalue', run_options.binomialpvalue, ...
                                         'shufflevalue', R.shufflecycle(k).radonmax);
%                                         radonoptions{:}, smoothoptions{:});
    
    
    R.shufflecycle(k).radonmax = [R.shufflecycle(k).radonmax;tmp1];
    R.shufflecycle(k).seed = [R.shufflecycle(k).seed;tmp2];
    R.shufflecycle(k).score = R.shufflecycle(k).radonmax ./ L(k);
    
    t=toc;
    
    disp(['cycle (' num2str(k) ') ' num2str(t) 's']);
    
  end
  
end    

%------------------------------------
%----CLUSTER PERMUTATION SHUFFLE-----
%------------------------------------

if run_options.nshuffleclperm>0
  
  if ~isfield(R, 'shuffleclperm')
    R.shuffleclperm = repmat(struct('radonmax',[],'seed', [], 'example',[]), [nseg,1] );
  end 
  
  for k=1:nseg
  
    %posE.viewport = R.info.segments(k,:);
    
% $$$     if isempty(R.shuffleclperm(k).example)
% $$$       [dummy dummy R.shuffleclperm(k).example] = ...
% $$$           replay_shuffle_clperm( posE, 1, 'binomialtest', 0, radonoptions{:}, smoothoptions{:}); %#ok
% $$$       R.shuffleclperm(k).example.score = ...
% $$$           R.shuffleclperm(k).example.radonmax ./ L(k);
% $$$     end
    
    tic;
    
    [tmp1, tmp2] = replay_shuffle_clperm( R.target(k), R.info, run_options.nshuffleclperm, ...
                                          'binomialpvalue', run_options.binomialpvalue, ...
                                          'shufflevalue', R.shuffleclperm(k).radonmax, ...
                                          'engine', posE);
%                                          radonoptions{:}, smoothoptions{:});
    
    
    R.shuffleclperm(k).radonmax = [R.shuffleclperm(k).radonmax;tmp1];
    R.shuffleclperm(k).seed = [R.shuffleclperm(k).seed;tmp2];
    R.shuffleclperm(k).score = R.shuffleclperm(k).radonmax ./ L(k);
    
    t=toc;
    
    disp(['clperm (' num2str(k) ') ' num2str(t) 's']);
    
  end
      
end
