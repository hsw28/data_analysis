function [R, posE] = detect_replay( varargin )
%DETECT_REPLAY replay detection
%
%  r=DETECT_REPLAY(spikes, behav_time, behav_pos, segments)
%
%  r=DETECT_REPLAY(r)
%
%  r=DETECT_REPLAY(...,parm1,val1,...)
%

%---------------------
%---CHECK ARGUMENTS---
%---------------------
if nargin<1
  %we need at least 1 argument
  help(mfilename)
  return
elseif isstruct(varargin{1}) && all( ismember( {'info'}, fieldnames( varargin{1}) ) )
  %first argument is a replay detection structure
  R = varargin{1}; 
  
  %check for selection and shuffle options
  options = struct( 'backup', '', ... %file to save results to
                    'selection', [], ... %selection of segments to process now
                    'nshufflepseudo', 0, ... %number of pseudo shuffles
                    'nshuffleclperm', 0, ... %number of cluster permutation shuffles
                    'nshufflecycle', 0, ... %number of randcycle shuffles
                    'minshuffles', 1000, ... %minimum number of shuffles before binomial shortcut
                    'maxshuffles', 2500, ... %maximum number of shuffles
                    'binomialtest', 1, ... %0/1 est chance of significance after every 50 shuffles
                    'binomialsuccess', 0.01, ... %probability of finding a shuffle>actual score
                    'binomialpvalue', 0.01 ); % maximum probability below which an event is
                                              % regarded non-significant and no more shuffle are performed
  
  options = parseArgs(varargin(2:end), options);

else
  %first 4 arguments are spikes, behavior time, linearized position and
  %time segments to be analyzed
  
  %check for options
  options = struct( 'backup', '', ...
                    'selection', [], ... %selection of segments to process now
                    'nshufflepseudo', 0, ... %number of pseudo shuffles
                    'nshuffleclperm', 0, ... %number of cluster permutation shuffles
                    'nshufflecycle', 0, ... %number of randcycle shuffles
                    'minshuffles', 1000, ... %minimum number of shuffles before binomial shortcut
                    'maxshuffles', 2500, ... %maximum number of shuffles
                    'binomialtest', 1, ... %0/1 est chance of significance after every 50 shuffles
                    'binomialsuccess', 0.01, ... %probability of finding a shuffle>actual score
                    'binomialpvalue', 0.01, ... % maximum probability below which no more shuffles are performed
                    'posgrid', [], ... %position grid (char)
                    'velgrid', [], ... %velocity grid (char)
                    'timebin', 0.02, ... %time bin size for reconstruction
                    'smoothkernel', 'box', ... %type of smoothing kernel ('box' or 'gauss')
                    'smooth', true, ... %yes/no smoothing of estimate before radon transform
                    'smooth_sd', [0 0 0], ... %smoothing stdev for position, velocity and time
                    'smoothcorrect', 1, ... %correct for smoothing at edges
                    'smooth_boxwidth', 3, ... %width of box kernel in bins (should be odd)
                    'radonmethod', 'sum', ... %radon transform method: 'sum','product','logsum'
                    'radonvalid', 0, ... %yes/no compute valid lines only (those that span full width/height of window)
                    'radoninterp', 'nearest', ... %interpolation: 'linear','nearest'
                    'thetarange', [-0.5 0.5].*pi, ... %range of theta values (currently not used)
                    'rho_x', 0, ... %0/1
                    'pad', 1, ... %yes/no padding of lines that do not span full width of window
                    'padmethod', 'median', ... %method of padding 'mean' of columns or 'random' draw from columns
                    'velsmooth_sd', 0.25 ); %smoothing stdev for velocity calculation
  
  [options, other, remainder] = parseArgs(varargin, options);

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
  
  %create info struct
  R.info = struct( 'date', datestr( now ), ...
                   'spikes', {other{1}}, ...
                   'behavior', behavior, ...
                   'segments', other{4}, ...
                   'posgrid', options.posgrid, ...
                   'velgrid', options.velgrid, ...
                   'timebin', options.timebin, ...
                   'smoothkernel', options.smoothkernel, ...
                   'smooth', options.smooth, ...
                   'smooth_sd', options.smooth_sd, ...
                   'smoothcorrect', options.smoothcorrect, ...
                   'smooth_boxwidth', options.smooth_boxwidth, ...
                   'radonmethod', options.radonmethod, ...
                   'radonvalid', options.radonvalid, ...
                   'thetarange', options.thetarange, ...
                   'rho_x', options.rho_x, ...
                   'radoninterp', options.radoninterp, ...
                   'pad', options.pad, ...
                   'padmethod', options.padmethod, ...
                   'velsmooth_sd', options.velsmooth_sd, ...
                   'engine_options', {remainder}); %options that are
                                                   %passed to the engine
  

  %round segment times to nearest multiple of R.info.timebin
  R.info.segments = [floorto(R.info.segments(:,1), R.info.timebin) ceilto(R.info.segments(:,2), R.info.timebin)];
  
  
end


%--------------------
%---INITIALIZATION---
%--------------------

if ~isempty(options.backup)
  options.backup = [options.backup '.mat'];
end

%total number of segments
nsegs = size(R.info.segments,1);

%selection of segments to analyze
if isempty(options.selection)
  options.selection = 1:nsegs;
end

%segment lengths in #bins
L = round( diff( R.info.segments, 1, 2)./R.info.timebin );

%in case of overlapping bins:
%overlap = 0.95;
%L = round( (diff(R.info.segments,1,2)-R.info.timebin) ./ ((1-overlap).*R.info.timebin) + 1 );

%unique window lengths in #bins of selected segments
[UL] = unique(L(options.selection)) ;

%number of segments to analyze
nselect = numel(options.selection);
%size of selected segments in bins
Lselect = L(options.selection);
%offset of selected segments (for use in concatenated matrix)
cumLselect = cumsum([1;Lselect]);

%position bin size
dpos = mean( diff( eval(R.info.posgrid ) ) );
%# position bins
npos = numel( eval( R.info.posgrid ) ) - 1;

if R.info.smooth && strcmp(R.info.smoothkernel, 'box')
  boxkernel = ones( R.info.smooth_boxwidth, 1 );
% $$$   ratio = R.info.smooth_boxwidth ./ dpos;
% $$$   if ratio>1 
% $$$     odd = floor( (ratio - 1)./2 ) * 2 + 1;
% $$$     boxkernel = ones( [odd+2 1] );
% $$$     boxkernel( [1 end] ) = (ratio - odd)./2;
% $$$   else
% $$$     boxkernel = [];
% $$$   end
end

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

%disable randomization
posE.randomizerate.enable=0;
posE.randomizebasis.enable=0;
  
%set engine viewport to include all selected segments
posE.viewport = R.info.segments(options.selection,:);

%compute estimate for all selected segments
est = execute_core(posE, {'estimate'});

%permute dimensions: position x time x velocity
est = permute( est, [1 3 2]);
%number of velocity bins
nvel = size( est, 3);

%create vector of sample sizes for smoothing
smooth_sample = [dpos R.info.timebin 1];
%find number of dimensions for smoothing
nd = double(2 + (nvel>1));

%create cell array with radon options
radonoptions = {'dx',1,'dy',1,'valid',R.info.radonvalid,...
                'interp', R.info.radoninterp, ...
                'rho_x', R.info.rho_x, ...
                'constraint', 'row', ...
                'method', R.info.radonmethod};

%---------------------
%---COMPUTE INDICES---
%---------------------

if strcmp(R.info.padmethod, 'random')
  cindex = struct('matrix', {}, 'invalid', {} );
  
  for j=1:numel(UL)
    
    %compute radon transform
    [radon,nn] = radon_transform( zeros(npos,UL(j))', radonoptions{:} ); 
    
    
    %construct index matrix
    cindex(UL(j)).matrix = bsxfun(@plus, zeros( size(radon) ), shiftdim( 1:UL(j), -1 ) );
    cindex(UL(j)).invalid = find( repmat(nn(:,:,1)==0,[1 1 UL(j)]) | ...
                                  ( repmat(nn(:,:,1),[1 1 UL(j)]) <= cindex(UL(j)).matrix  & ...
                                    repmat(nn(:,:,2), [1 1 UL(j)]) >= cindex(UL(j)).matrix ) ) ;
    cindex(UL(j)).matrix = (cindex(UL(j)).matrix-1).*npos;
  end
end

%-----------------------------
%---COMPUTE RADON TRANSFORM---
%-----------------------------

%initialize structure
if ~isfield(R, 'target')
  R.target = struct('success', repmat( {false}, nsegs, 1 ) );
end

%store estimates
tmp = mat2cell( est, npos, Lselect, nvel);
[R.target(options.selection(1:nselect)).estimate_vel] = deal( tmp{:} );

tmp = mat2cell( sum(est,3), npos, Lselect );
[R.target(options.selection(1:nselect)).estimate] = deal( tmp{:} );  
      
%smooth estimate
smest = smooth_estimate( est );
    
start = now;

%loop through all selected segments
for k=1:nselect
    
  %skip if already processed
  if R.target(options.selection(k)).success
    continue
  end
    
  %store segment
  R.target(options.selection(k)).segment = R.info.segments(options.selection(k),:);
    
  %compute radon for each velocity
  for j=1:nvel
    
    [R.target(options.selection(k)).radon_vel(:,:,j),nn] = radon_transform( smest(:,cumLselect(k):(cumLselect(k+1)-1),j)', radonoptions{:} );
    
    
    R.target(options.selection(k)).radon_vel(:,:,j) = pad_radon( ...
        R.target(options.selection(k)).radon_vel(:,:,j), nn, smest(:,cumLselect(k):(cumLselect(k+1)-1),j), ...
        L(options.selection(k)) );
    
  end
  
  %compute radon for position estimate
  sumsmest = sum(smest(:,cumLselect(k):(cumLselect(k+1)-1),:),3);
  
  [R.target(options.selection(k)).radon, nn, settings] = radon_transform( sumsmest', radonoptions{:} );
 
  R.target(options.selection(k)).radon = pad_radon( ...
      R.target(options.selection(k)).radon, nn, sumsmest, L(options.selection(k)) );
  
  %store theta and rho vectors
  R.target(options.selection(k)).theta = settings.theta;
  R.target(options.selection(k)).rho = settings.rho;
  %find maximum
  [R.target(options.selection(k)).radonmax, idx] = max( R.target(options.selection(k)).radon(:) );
  [idx(1) idx(2)] = ind2sub( size( R.target(options.selection(k)).radon ), idx );
  %store theta and rho at maximum
  R.target(options.selection(k)).thetamax = settings.theta( idx(1) );
  R.target(options.selection(k)).rhomax = settings.rho( idx(2) );    
  %store value in velocity slabs at maximum
  R.target(options.selection(k)).radonmax_vel = squeeze(R.target(options.selection(k)).radon_vel(idx(1), idx(2),: ))';
  %store start and end bin
  R.target(options.selection(k)).line_columns = squeeze(nn(idx(1), idx(2),:));
  
  %compute projections for velocity slabs
  for j=1:nvel  
    R.target(options.selection(k)).radon_projection_vel(j) = radon_transform(smest(:,cumLselect(k):(cumLselect(k+1)-1),j)',...
                                                      R.target(options.selection(k)).thetamax,R.target(options.selection(k)).rhomax,...
                                                      radonoptions{:}, ...
                                                      'method', 'slice' );
    %pad projection
    R.target(options.selection(k)).radon_projection_vel{j} = pad_projection( ...
        R.target(options.selection(k)).radon_projection_vel{j}, ...
        R.target(options.selection(k)).line_columns, ...
        smest(:,cumLselect(k):(cumLselect(k+1)-1),j), L(options.selection(k)) );
  
    
    R.target(options.selection(k)).mode_projection_vel(:,j) = max(smest(:,cumLselect(k):(cumLselect(k+1)-1),j));
  end
    
  R.target(options.selection(k)).radon_projection_vel = horzcat(R.target(options.selection(k)).radon_projection_vel{:});
    
  %compute projection for estimate
  R.target(options.selection(k)).radon_projection = radon_transform( sumsmest',...
                                                    R.target(options.selection(k)).thetamax, R.target(options.selection(k)).rhomax, ...
                                                    radonoptions{:}, ...
                                                    'method', 'slice' );
    
  R.target(options.selection(k)).radon_projection = R.target(options.selection(k)).radon_projection{1};
  
  R.target(options.selection(k)).mode_projection(:,1) = max(sumsmest);  
  
  %pad projection
  R.target(options.selection(k)).radon_projection = pad_projection( ...
      R.target(options.selection(k)).radon_projection, ...
      R.target(options.selection(k)).line_columns, ...
      sumsmest, L(options.selection(k)) );  
  
  R.target(options.selection(k)).success=true;
    
end
  
start = datevec(now-start);
start = sum( start(4:6).*[60*60 60 1] );
disp(['Radon (n=' num2str(nselect) ', ' num2str(start) ' seconds)'] )  
  
%-----------------------------


%-----BACKUP RESULTS-----
if ~isempty(options.backup)
  if isempty(dir(options.backup))
    save(options.backup, '-struct', 'R', 'info', 'target')
  else
    save(options.backup, '-struct', 'R', 'info', 'target', '-append' )
  end
end
%---END BACKUP RESULTS---

%collapse along velocity dimension
est = sum(est, 3); 

%create nosig vector
nosig( 1:nselect ) = 0;


%---------------------------
%---PSEUDO EVENT SHUFFLES---
%---------------------------

%initialize structure
if ~isfield(R, 'shufflepseudo')
    [R.shufflepseudo(1:max(L)).radonmax] = deal([]);
    [R.shufflepseudo(1:max(L)).radonsum] = deal(0);
    [R.shufflepseudo(1:max(L)).radonsumsq] = deal(0);
    [R.shufflepseudo(1:max(L)).radonmaxall] = deal(NaN);
else
    
    %initialize nosig vector
    for k=1:nselect
        nosig(k) = nosig(k) | prob_significance( R.target(options.selection(k)).radonmax, ...
                                                 R.shufflepseudo(Lselect(k)).radonmax )<options.binomialpvalue;        
    end
    
end

if options.nshufflepseudo>0

  %disable randomization
  posE.randomizerate.enable=0;
  %set viewport to all segments
  posE.viewport = R.info.segments;

  %compute estimate
  smest = execute_core(posE, {'estimate'});
  smest = permute( smest, [1 3 2]); %permute dimensions
  smest = sum(smest, 3); %collapse along velocity dimension

  %smooth estimate
  smest = smooth_estimate( smest );
  
  %loop through all possible window sizes
  for j=1:numel(UL)
    
    start = now;    

    %loop through number of requested shuffles
    for k=1:options.nshufflepseudo
      
      %test if significance is likely 
      if mod(k,50)==0 %every 50 shuffles update nosig
        loopidx = find( L(options.selection)==UL(j) )';
        for w=loopidx
          
          nosig(w) = nosig(w) | prob_significance( R.target(options.selection(w)).radonmax, ...
                                                   R.shufflepseudo(UL(j)).radonmax )<options.binomialpvalue;
        end
        if (numel(R.shufflepseudo(UL(j)).radonmax)>=options.maxshuffles) || ((numel(R.shufflepseudo(UL(j)).radonmax) >= options.minshuffles) && all( nosig( L(options.selection)==UL(j) ) ))
          break
        end
      end
      
      %sample randomly from estimate
      c = randsample( size(smest,2), UL(j) );
    
      %compute radon transform
      [radon,nn] = radon_transform( smest(:,c)', radonoptions{:} );
      
      radon = pad_radon( radon, nn, smest(:,c), UL(j) );

      %find maximum
      R.shufflepseudo(UL(j)).radonmax(end+1) = max( radon(:) );     

      %store running sum and sum squares
% $$$       R.shufflepseudo(UL(j)).radonsum = R.shufflepseudo(UL(j)).radonsum + exp(radon);
% $$$       R.shufflepseudo(UL(j)).radonsumsq = R.shufflepseudo(UL(j)).radonsumsq + exp(radon).^2;      
% $$$       R.shufflepseudo(UL(j)).radonmaxall = max( R.shufflepseudo(UL(j)).radonmaxall, radon );
    end
    
    start = datevec(now-start);
    start = sum( start(4:6).*[60*60 60 1] );
    disp(['pseudo ' num2str(j) '[' num2str(UL(j)) '] (' num2str(start) ' seconds)'] )      
    
    %-----BACKUP RESULTS-----
    if ~isempty(options.backup)
      save(options.backup, '-struct', 'R', 'shufflepseudo', '-append' )
    end
    %---END BACKUP RESULTS---

  end
  
end

%-----BACKUP RESULTS-----
if ~isempty(options.backup)
  save(options.backup, '-struct', 'R', 'shufflepseudo', '-append' )
end
%---END BACKUP RESULTS---



%------------------------
%---RANDCYCLE SHUFFLES---
%------------------------

%initialize structure
if ~isfield(R, 'shufflecycle')
    [R.shufflecycle(options.selection(1:nselect)).radonmax] = deal([]);
    [R.shufflecycle(options.selection(1:nselect)).radonsum] = deal(0);
    [R.shufflecycle(options.selection(1:nselect)).radonsumsq] = deal(0);
    [R.shufflecycle(options.selection(1:nselect)).radonmaxall] = deal(NaN);
else
    
    %initialize nosig vector
    for k=1:nselect
        nosig(k) = nosig(k) | prob_significance( R.target(options.selection(k)).radonmax, ...
                                                 R.shufflecycle(options.selection(k)).radonmax )<options.binomialpvalue;
    end
end

if options.nshufflecycle>0

  %loop through number of requested shuffles
  for j=1:options.nshufflecycle
    
    %test if significance is likely 
    if mod(j,50)==0 %every 50 shuffles update nosig
      for k=1:nselect
        nosig(k) = nosig(k) | prob_significance( R.target(options.selection(k)).radonmax, ...
                                                 R.shufflecycle(options.selection(k)).radonmax )<options.binomialpvalue;
      end
      
      %-----BACKUP RESULTS-----
      if ~isempty(options.backup)
        save(options.backup, '-struct', 'R', 'shufflecycle', '-append' )
      end
      %---END BACKUP RESULTS---      
      
    end
    
    start = now;
    
    %randomize estimate
    smest = randomize( est, 1, 'method', 'cycle');
    
    %smooth estimate
    smest = smooth_estimate( smest );
    
    %loop through selected segments
    for k=1:nselect

      if (numel(R.shufflecycle(options.selection(k)).radonmax)>=options.maxshuffles) || ((numel(R.shufflecycle(options.selection(k)).radonmax)>=options.minshuffles) && nosig(k))
        continue
      end
      
      %compute radon transform
      [radon,nn] = radon_transform( smest(:,cumLselect(k):(cumLselect(k+1)-1))', ...
                                    radonoptions{:} );

      radon = pad_radon( radon, nn, smest(:,cumLselect(k):(cumLselect(k+1)-1)), ...
                         L(options.selection(k)) );
      
      %find maximum
      R.shufflecycle(options.selection(k)).radonmax(end+1) = max( radon(:) );
      
      %store running sum and sum squares
% $$$       R.shufflecycle(options.selection(k)).radonsum = ...
% $$$           R.shufflecycle(options.selection(k)).radonsum + exp(radon);
% $$$       R.shufflecycle(options.selection(k)).radonsumsq = ...
% $$$           R.shufflecycle(options.selection(k)).radonsumsq + exp(radon).^2;
% $$$       R.shufflecycle(options.selection(k)).radonmaxall = ...
% $$$           max( R.shufflecycle(options.selection(k)).radonmaxall, ...
% $$$                radon );
    end
    
    start = datevec(now-start);
    start = sum( start(4:6).*[60*60 60 1] );
    disp(['Rand cycle ' num2str(j) ' (' num2str(start) ' seconds)'] )      
    
  end
  
end

%-----BACKUP RESULTS-----
if ~isempty(options.backup)
  save(options.backup, '-struct', 'R', 'shufflecycle', '-append' )
end
%---END BACKUP RESULTS---  



%----------------------------------
%---CLUSTER PERMUTATION SHUFFLES---
%----------------------------------

%initialize structure
if ~isfield(R, 'shuffleclperm')
    [R.shuffleclperm(options.selection(1:nselect)).radonmax] = deal([]);
    [R.shuffleclperm(options.selection(1:nselect)).radonsum] = deal(0);
    [R.shuffleclperm(options.selection(1:nselect)).radonsumsq] = deal(0);
    [R.shuffleclperm(options.selection(1:nselect)).radonmaxall] = deal(NaN);
else
    
    %initialize nosig vector
    for k=1:nselect
        nosig(k) = nosig(k) | prob_significance( R.target(options.selection(k)).radonmax, ...
                                                 R.shuffleclperm(options.selection(k)).radonmax )<options.binomialpvalue;
    end
    
end

sig_idx = find( (nosig == 0 | cellfun('prodofsize',{R.shuffleclperm(options.selection).radonmax})<options.minshuffles) & cellfun('prodofsize',{R.shuffleclperm(options.selection).radonmax})<options.maxshuffles );

if options.nshuffleclperm>0 && ~isempty(sig_idx)

  %enable randomization of rate matrix
  posE.randomizerate.enable = 1;
  posE.randomizerate.method = 'swap';
  posE.randomizerate.dim = 1;
  posE.randomizerate.groupdim = 2;
  
  %set engine viewport to include all selected segments which could be
  %significant
  posE.viewport = R.info.segments(options.selection(sig_idx),:);
  %recompute cumLselect
  cumLselect = cumsum([1;Lselect(sig_idx)]);
  
  %loop through number of requested shuffles
  for j=1:options.nshuffleclperm

    
    %test if significance is likely 
    if mod(j,50)==0 %every 50 shuffles update nosig
      for k=1:nselect
        nosig(k) = nosig(k) | prob_significance( R.target(options.selection(k)).radonmax, ...
                                                 R.shuffleclperm(options.selection(k)).radonmax )<options.binomialpvalue;
      end

      %set engine viewport to include all selected segments which could be
      %significant
      sig_idx = find( (nosig == 0 | cellfun('prodofsize',{R.shuffleclperm(options.selection).radonmax})<options.minshuffles) & cellfun('prodofsize',{R.shuffleclperm(options.selection).radonmax})<options.maxshuffles );
      
      if isempty(sig_idx)
        break;
      end
      
      posE.viewport = R.info.segments(options.selection(sig_idx),:);
      %recompute cumLselect
      cumLselect = cumsum([1;Lselect(sig_idx)]);
      
      %-----BACKUP RESULTS-----
      if ~isempty(options.backup)
        save(options.backup, '-struct', 'R', 'shuffleclperm', '-append' )
      end
      %---END BACKUP RESULTS---    
      
    end    
    
    start = now;    
    
    %reset randomization engine
    reset(posE, 'randomizerate');
    
    %compute estimate for all selected segments
    smest = execute_core(posE, {'estimate'});
    smest = permute( smest, [1 3 2]); %permute dimensions
    smest = sum(smest, 3); %collapse along velocity dimension    
    
    %smooth estimate
    smest = smooth_estimate( smest );
    
    %loop through all selected segments which are 
    for k=1:numel(sig_idx)
      
      if (numel(R.shuffleclperm(options.selection(sig_idx(k))).radonmax)>=options.maxshuffles) || ((numel(R.shuffleclperm(options.selection(sig_idx(k))).radonmax)>=options.minshuffles) && nosig(sig_idx(k)))
        continue
      end      
      
      %compute radon transform
      [radon, nn] = radon_transform( smest(:,cumLselect(k):(cumLselect(k+1)-1))', ...
                                     radonoptions{:} );
      
      radon = pad_radon( radon, nn, smest(:,cumLselect(k):(cumLselect(k+1)-1)), ...
                         L(options.selection(sig_idx(k))) );
      
      %find maximum
      R.shuffleclperm(options.selection(sig_idx(k))).radonmax(end+1) = max( radon(:) );      
    
      %store running sum and sum squares
% $$$       R.shuffleclperm(options.selection(k)).radonsum = ...
% $$$           R.shuffleclperm(options.selection(k)).radonsum + exp(radon);
% $$$       R.shuffleclperm(options.selection(k)).radonsumsq = ...
% $$$           R.shuffleclperm(options.selection(k)).radonsumsq + exp(radon).^2;      
% $$$       R.shuffleclperm(options.selection(k)).radonmaxall = ...
% $$$           max( R.shuffleclperm(options.selection(k)).radonmaxall, ...
% $$$                radon );      
    end
    
    start = datevec(now-start);
    start = sum( start(4:6).*[60*60 60 1] );
    disp(['clperm ' num2str(j) ' (' num2str(start) ' seconds)'] )     

    
  end
  
end

%-----BACKUP RESULTS-----
if isfield(R, 'shuffleclperm')
  if ~isempty(options.backup)
    save(options.backup, '-struct', 'R', 'shuffleclperm', '-append' )
  end
end
%---END BACKUP RESULTS---  




  function est = smooth_estimate( est )

  if R.info.smooth
    switch R.info.smoothkernel
     case 'box'
      if ~isempty( boxkernel )
        est = convn( est, boxkernel, 'same');
      end
     otherwise
      est = smoothn( est, R.info.smooth_sd(1:nd), smooth_sample(1:nd), ...
                     'nanexcl', 1, 'correct', R.info.smoothcorrect);       
    end
  end
  
  end

  
  function result = test_nosig( val, trials )
    
    result = 0;
    
    if options.binomialtest
          
      NN = numel(trials);
      
      if NN==0
        return
      end
      
      kk = numel(find(trials>val));
      
      if (kk/NN) > min(options.binomialsuccess,2./numel(trials))
        result = ( binopdf( kk, NN, min(options.binomialsuccess,2./numel(trials)) ) < options.binomialpvalue );
      end
      
    end    
    
  end
  
  
  function P = prob_significance( val, trials )

  %imagine a distribution of shuffle scores
  %and p = probability of drawing a shuffle score < real score
  %H0: p>=alpha
  %H1: p<alpha
  %X = # shuffle scores < real score
  %then what is the probability of drawing k or fewer shuffle scores
  %smaller than the real score, given p=alpha and number of drawings N
  %P( X<=k | n=N, p=alpha )

  P=1;

  %number of trials
  N = numel(trials);

  if N==0
    return
  end
  
  alpha = 1./N;
  
  k = numel( find( trials < val ) );
  
  P = binocdf( k, N, 1-alpha );
  
  %if P<pvalue, then we'll reject H0 and thus the real score is NOT
  %significant

  end
  
  function result = pad_projection( p, nn, est, winL )
    
    if R.info.pad
      switch R.info.padmethod
       case 'median'
        result = median( est )';
        result( nn(1):nn(2) ) = p(:);
       case 'mean'
        result = mean( est )';
        result( nn(1):nn(2) ) = p(:);
       case 'geomean'
        result = geomean( est )';
        result( nn(1):nn(2) ) = p(:);
       case 'random'
        result = est( unidrnd( size(est,1), [1 winL] ) + (0:(winL-1)).*size(est,1) )';
        result( nn(1):nn(2) ) = p(:);
      end
    else
      result = NaN( winL, 1 );
      result(nn(1):nn(2)) = p(:);
    end
  end
  

  function r = pad_radon( r, nn, est, winL )
  
  if R.info.pad
    switch R.info.padmethod
     case 'median'
      switch R.info.radonmethod
       case 'sum'
        %compute median
        medest = median( est );
        %compute cumulative sums
        cpstart = [0 0 cumsum( medest(1:end-1) ) ];
        cpend = [0 fliplr( cumsum( medest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
       case 'logsum'
        %compute median
        medest = log( median( est ) );
        %compute cumulative sums
        cpstart = [0 0 cumsum( medest(1:end-1) ) ];
        cpend = [0 fliplr( cumsum( medest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );       
       case 'product'
        %compute median
        medest = median( est );
        %compute cumulative sums
        cpstart = [0 0 cumprod( medest(1:end-1) ) ];
        cpend = [0 fliplr( cumprod( medest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r .* cpstart( nn(:,:,1)+1 ) .* cpend( nn(:,:,2)+1 );          
      end
     case 'mean'
      switch R.info.radonmethod
       case 'sum'
        r = r + (winL-double(diff(nn,1,3)+1))./npos;        
       case 'logsum'
        r = r + (winL-double(diff(nn,1,3)+1)).*log(1./npos);
       case 'product'
        r = r .* (1./npos).^(winL-double(diff(nn,1,3)+1));
      end
     case 'geomean'
      switch R.info.radonmethod
       case 'sum'
        %compute geometric mean
        geoest = geomean( est );
        %compute cumulative products
        cpstart = [0 0 cumsum( geoest(1:end-1) ) ];
        cpend = [0 fliplr( cumsum( geoest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
       case 'logsum'
        %compute mean of the log
        logest = mean( log(est) );
        %compute cumulative sums
        cpstart = [0 0 cumsum( logest(1:end-1) ) ];
        cpend = [0 fliplr( cumsum( logest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
       case 'product'
        %compute geometric mean
        geoest = geomean( est );
        %compute cumulative products
        cpstart = [0 0 cumprod( geoest(1:end-1) ) ];
        cpend = [0 fliplr( cumprod( geoest( end:-1:2 ) ) ) 0];
        %apply padding
        r = r .* cpstart( nn(:,:,1)+1 ) .* cpend( nn(:,:,2)+1 );      
      end
     case 'random'
      switch R.info.radonmethod
       case 'sum'
        tmp = est( cindex(winL).matrix + unidrnd(npos, [size(r) winL]) );
        tmp( cindex(winL).invalid ) = 0;
        r = r + sum( tmp, 3 );      
       case 'logsum'
        tmp = log(est);
        tmp = tmp( cindex(winL).matrix + unidrnd(npos, [size(r) winL]) );
        tmp( cindex(winL).invalid ) = 0;
        r = r + sum( tmp, 3 );
        %r = log( exp(r) .* prod( tmp, 3 ) );
       case 'product'
        tmp = est( cindex(winL).matrix + unidrnd(npos, [size(r) winL]) );
        tmp( cindex(winL).invalid ) = 1;
        r = r .* prod( tmp, 3 );
      end
    end
  end
  
  end

end
