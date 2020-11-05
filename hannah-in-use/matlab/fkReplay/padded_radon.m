function [radon,nn,settings]=padded_radon(estimate, varargin)
%PADDED_RADON

if nargin<1
  help(mfilename)
  return
end

options = struct('pad', 0, 'padmethod', 'mean', 'index', [], ...
                 'method', 'sum');

[options, other, radonoptions] = parseArgs(varargin, options);
radonoptions = horzcat( radonoptions, {'method', options.method});

[npos winL dummy] = size(estimate); %#ok

[radon,nn,settings] = radon_transform( estimate', radonoptions{:} );

if options.pad && isempty(options.index) && isequal(options.padmethod, 'random')
  options.index = generate_radon_indices(npos, winL, radonoptions);
end

switch options.padmethod
 case 'median'
  switch options.method
   case 'sum'
    %compute median
    medest = median( estimate );
    %compute cumulative sums
    cpstart = [0 0 cumsum( medest(1:end-1) ) ];
    cpend = [0 fliplr( cumsum( medest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
   case 'logsum'
    %compute median
    medest = log( median( estimate ) );
    %compute cumulative sums
    cpstart = [0 0 cumsum( medest(1:end-1) ) ];
    cpend = [0 fliplr( cumsum( medest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );       
   case 'product'
    %compute median
    medest = median( estimate );
    %compute cumulative sums
    cpstart = [0 0 cumprod( medest(1:end-1) ) ];
    cpend = [0 fliplr( cumprod( medest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon .* cpstart( nn(:,:,1)+1 ) .* cpend( nn(:,:,2)+1 );          
  end
 case 'mean'
  switch options.method
   case 'sum'
    radon = radon + (winL-double(diff(nn,1,3)+1))./npos;        
   case 'logsum'
    radon = radon + (winL-double(diff(nn,1,3)+1)).*log(1./npos);
   case 'product'
    radon = radon .* (1./npos).^(winL-double(diff(nn,1,3)+1));
  end
 case 'geomean'
  switch options.method
   case 'sum'
    %compute geometric mean
    geoest = geomean( estimate );
    %compute cumulative products
    cpstart = [0 0 cumsum( geoest(1:end-1) ) ];
    cpend = [0 fliplr( cumsum( geoest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
   case 'logsum'
    %compute mean of the log
    logest = mean( log(estimate) );
    %compute cumulative sums
    cpstart = [0 0 cumsum( logest(1:end-1) ) ];
    cpend = [0 fliplr( cumsum( logest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon + cpstart( nn(:,:,1)+1 ) + cpend( nn(:,:,2)+1 );
   case 'product'
    %compute geometric mean
    geoest = geomean( estimate );
    %compute cumulative products
    cpstart = [0 0 cumprod( geoest(1:end-1) ) ];
    cpend = [0 fliplr( cumprod( geoest( end:-1:2 ) ) ) 0];
    %apply padding
    radon = radon .* cpstart( nn(:,:,1)+1 ) .* cpend( nn(:,:,2)+1 );      
  end
 case 'random'
  switch options.method
   case 'sum'
    tmp = estimate( options.index.matrix + unidrnd(npos, [size(radon) winL]) );
    tmp( options.index.invalid ) = 0;
    radon = radon + sum( tmp, 3 );      
   case 'logsum'
    tmp = log(estimate);
    tmp = tmp( options.index.matrix + unidrnd(npos, [size(radon) winL]) );
    tmp( options.index.invalid ) = 0;
    radon = radon + sum( tmp, 3 );
    %r = log( exp(r) .* prod( tmp, 3 ) );
   case 'product'
    tmp = estimate( options.index.matrix + unidrnd(npos, [size(radon) winL]) );
    tmp( options.index.invalid ) = 1;
    radon = radon .* prod( tmp, 3 );
  end
end
