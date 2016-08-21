function [energy, pc]=pcafeatures(ttfile,varargin)
%PCAFEATURES compute principal component features
%
%  [energy,pc]=PCAFEATURES(ttfile)
%
%  [...]=PCAFEATURES(ttfile,n) returns the n largest principal components
%
%  [...]=PCAFEATURES(...,'index',[start end])
%
%  [...]=PCAFEATURES(...,'time',[start end])
%

nchan = 4;
nsamples = 32;

%open file
f=mwlopen(ttfile);

options = struct('index', [], 'time', [], 'nload', 10000);
[options,other] = parseArgs(varargin,options);

if isempty(other)
  npca=1;
else
  npca = other{1};
end

if ~isempty(options.index) && ~isempty(options.time)
  error('pcafeatures:invalidOptions', ['Specify either index or time option, ' ...
                      'not both'])
elseif ~isempty(options.index)
  idx = options.index;
elseif ~isempty(options.time)
  idx = findrecord( ttfile, options.time*10000, {0,13,1}, f.headersize, nchan*nsamples*2+4 );
else
  idx = [1 get(f, 'nrecords')]-1;
end

n = diff(idx)+1;
nload = options.nload;
nloops = ceil( n ./ nload );

Sxy = zeros( nsamples, nsamples, nchan );
Sx = zeros( nsamples, nchan);
energy = [];

for k=1:nloops
 
  loadidx = [0 (nload-1)] + (k-1)*nload + idx(1);
  loadidx = min( loadidx, idx(2) );
  
  %load waveforms, data will be a nsamples x nspikes x nchan matrix
  data = load( f, 'waveform', loadidx(1):loadidx(2) );
  data = permute( double( data.waveform ), [2 3 1] );
  
  %compute energy: E=||w||/n
  E=squeeze( sqrt( sum( data.^2 ) ) ./ nsamples );
  energy = [energy; E];
  
  %normalize data to energy
  data = bsxfun(@rdivide, data, shiftdim(E,-1) );
  
  %sum of xy
  for c=1:nchan
    Sxy(:,:,c) = Sxy(:,:,c) + (data(:,:,c)*data(:,:,c)');
  end
  
  %sum of x
  Sx = Sx + squeeze( sum( data, 2 ) );

end
  
%compute sample covariance: sum(XY)/(n-1) - n*mean(X)*mean(Y)/(n-1)
covariance=zeros( nsamples, nsamples, nchan ); %#ok
for c=1:nchan
  covariance(:,:,c) = Sxy(:,:,c)./(n-1) - Sx(:,c)*Sx(:,c)'./(n*(n-1));
end

%compute eigenvector and eigenvalues of covariance matrix
for c=1:nchan
  [eigvec(:,:,c), eigval(:,:,c)] = eig( covariance(:,:,c) );
end


%loop again through all waveforms to compute pca scores
for k=1:nloops
 
  loadidx = [0 (nload-1)] + (k-1)*nload + idx(1);
  loadidx = min( loadidx, idx(2) );

  nlocal = diff(loadidx)+1;
  idxlocal = (k-1)*nload + (1:nlocal);

  %load waveforms, data will be a nspikes x nsamples x nchan matrix
  data = load( f, 'waveform', loadidx(1):loadidx(2) );
  data = permute( double( data.waveform ), [3 2 1] );
  
  %normalize data to energy
  data = bsxfun(@rdivide, data, reshape( energy(idxlocal,:), numel(idxlocal), 1, nchan ) );
  
  %pca scores of npca largest principal components
  for c=1:nchan
    pc(idxlocal,1:npca,c) = data(:,:,c)*eigvec(:,end:-1:(end-npca+1),c);
  end
  
end


