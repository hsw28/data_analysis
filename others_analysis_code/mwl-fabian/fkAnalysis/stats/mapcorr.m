function [c, lags]=mapcorr(a,varargin)
%MAPCORR spatial correlation of maps
%
%  c=MAPCORR(a) computes the spatial normalized autocorrelation of a map.
%
%  c=MAPCORR(a,b) computes the spatial normalized crosscorrelation of two
%  maps.
%
%  [c,lags]=MAPCORR(a,b) returns cell array with x and y lags.
%
%  [...]=MAPCORR(...,param,val,...) additional parameter/value
%  pairs. Valid parameters are:
%   fft - 0/1 use FFT to compute xcorr (faster, but less accurate?)
%   

%check input arguments
if nargin<1
  help(mfilename)
end

options = struct( 'fft', 0 );
[options, other] = parseArgs(varargin,options);

if isempty(other)
  b=a; %autocorrelation
else
  b = other{1};
end

%sizes of input maps
[ra, ca] = size(a);
[rb, cb] = size(b);

%size of output
nr = ra+rb-1;
nc = ca+cb-1;

%pre-allocate output
c = NaN( nr, nc );

%find valid elements
valida = ~isnan(a);
validb = ~isnan(b);

%set invalid entires to zero
a(~valida)=0;
b(~validb)=0;

if options.fft
  fcn = @(A,B) freqxcorr2( A, B, [nr nc] );
else
  fcn = @xcorr2;
end

%do correlation
n = fcn( double(valida), double(validb) ); %number of valid entries in a
                                          %and b for each lag

ab = fcn( a, b ); % raw correlation
an = fcn( a, double(valida) );
bn = fcn( double(validb), b );

as = n.*fcn( a.^2, double(valida) ) - an.^2;
bs = n.*fcn( double(validb), b.^2 ) - bn.^2;

den = (sqrt(as).*sqrt(bs));
valid = den~=0;

%compute final correlation
c(valid) = (n(valid).*ab(valid) - an(valid).*bn(valid))./den(valid);

lags = { (0:(nr-1))-(nr-1)./2 , (0:(nc-1))-(nc-1)./2  };



function xcorr_ab = freqxcorr2(a,b,outsize)
  
% calculate correlation in frequency domain
Fa = fft2(rot90(a,2),outsize(1),outsize(2));
Fb = fft2(b,outsize(1),outsize(2));
xcorr_ab = real(ifft2(Fa .* Fb));




%slow method

%check input arguments
%if nargin<1
%  help(mfilename)
%elseif nargin<2
%  b=a; %autocorrelation
%end

%sizes of input maps
%[ra, ca] = size(a);
%[rb, cb] = size(b);

%size of output
%nr = ra+rb-1;
%nc = ca+cb-1;

%pre-allocate output
%c = NaN( nr, nc );

%find valid elements
%valida = ~isnan(a);
%validb = ~isnan(b);

%for k=1:nr
  
%  ria = max(1,k-rb+1):min(ra,k);
%  rib = max(1,rb-k+1):min(rb,nr-k+1);
  
%  for l=1:nc
    
%    cia = max(1,l-cb+1):min(ca,l);
%    cib = max(1,cb-l+1):min(cb,nc-l+1);
   
%    valid = valida(ria,cia) & validb(rib,cib);
    
%    nvalid = numel( find( valid ) );
      
%    suba = a(ria,cia);
%    suba = suba(valid);
    
%    subb = b(rib,cib);
%    subb = subb(valid);
    
%    suma = sum(suba);
%    sumb = sum(subb);
    
%    if nvalid<2 %20
%      continue
%    end    
    
%    c(k,l) = nvalid.*sum(suba.*subb)-suma.*sumb;

%    c(k,l) = c(k,l) ./ ( sqrt(nvalid.*sum(suba.^2)-suma.^2).*sqrt(nvalid.*sum(subb.^2)-sumb.^2) );
    
%  end
  
%end


