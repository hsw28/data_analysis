function [y, bdu, bdl, auto_a, auto_b,lags] = xcorrc(a,b,flag,rep,perc);

% [y, bdu, bdl, yy] = xcorrc(a,b,flag,rep,perc);
%
% Cross correlation with confidence interval calculation. Similar
% to Matlab's xcorr but here (perc*100)% confidence intervals are
% calculated (default 90% confidence intervals, i.e. perc=0.9) for
% a random phase distribution of one time series. The confidence 
% interval is given as upper bound (bdu) and lower bound (bdl) 
% based on 'rep' repetitions (Monte Carlo approach). 
% One of the channels (does not matter which (but can't be both)) 
% has its phases randomly changed over a range of 2pi. This
% way the auto-correlation is kept unchanged (internal structure is 
% unchanged). If both channels' phases were randomly changed, the
% result for confidence intervals in cross-correlation would always
% be the same (i.e., the result for 2 random time series).
%
% y=xcorrc(a,b, ...) where a and b are length M vectors (M>1), returns the
% length 2*M-1 cross-correlation sequence y. If A and B are of
% different length, the shortest one is zero-padded. Zero time lag
% coefficient is located in y(M). 
%
% The correlation coefficients are automatically normalized to lie
% between -1 and 1 (except when flag='unbiased' is set where values 
% >1 and <-1 can occure at "large" positive and negative time
% lags), so flag = 'coeff' is redundent. 
% However 'xcorrc' can be used without confidence interval calculation by
% setting rep=0 or by not specifying rep at all.  'xcorrc' allows 
% for calculation of normalized cross correlation coefficients and
% usage of flag='unbiased' at the same time (not possible in
% original Matlab function xcorr where either flag='coeff' for
% normalization or flag='unbiased' for unbiased calculation).
%
% 'xcorrc' calculates confidence intervals by performing cross 
% correlation as spectral multiplication where the complex
% conjugate of the lag channel is used in the frequency
% domain. This is a 'biased' cross correlation, meaning that
% correlation coefficients at large positive and negative time lags 
% are getting smaller because the length of overlap between the two 
% time series (as viewed in the time domain) gets smaller.
%
% For test purposes the result from cross correlation by spectral
% multiplication is returned in yy and can be compared with y
% (which is obtained from the standard Matlab function 'xcorr').
% y and yy should be identical if flag='biased' or 'none' (which
% automatically assumes the default 'biased') is chosen.
%
% One can also set flag='unbiased' so that y contains the unbiased 
% cross correlation coefficients and the confidence interval
% between upper bound (bdu) and lower bound (bdl) are still
% calculated (however in a biased way). In any case, yy will always 
% contain biased cross correlation coefficients.
%
%
% Example of usage:
%
% To calculate unbiased cross correlation coefficients with 99%
% confidence intervals based on 100 random distributions of one 
% time series try:
%
% t=0:0.1:10*pi;
% a = cos(t);
% b = sin(t);
%
% [cross up lo] = xcorrc(a,b,'unbiased',100,0.99);
%
% figure;
% plot(cross); hold on;
% plot(up,'k-');
% plot(lo,'k-');
%
% Now 99% of all cross correlation coefficients would fall between the two 
% black (~horizontal) lines if one time series has random
% distribuitions of values with time (while its auto-correlation
% remained unchanged).
%
% Martin Saar (Oct. 2002); Minor mods by jellinek july, 2004.
%

if exist('flag')==0 flag='none'; end
% if b is a character then it is the flag, thus do auto-correlation of a:
if ischar(b) == 1   
  flag = b;
  b    = a; 
end

% zero-pad shorter time series if necessary (so that length(a)=length(b):
if length(a) < length(b) a = [a zeros(1,length(b)-length(a))]; end
if length(b) < length(a) b = [b zeros(1,length(a)-length(b))]; end
len = length(a); % also equal to length(b)


%====== standard cross correlation ===================================
% Only difference to xcorr is that normalization is done
% automatically so flag='coeff' is unnecessary. Instead 
% one can use other flag options such as 'biased' or 'unbiased'
% and thus get a normalized and biased/unbiased result.

auto_a = xcorr(a,flag);
auto_b = xcorr(b,flag);
[y,lags] = xcorr(a,b,flag);
% normalize by values at zero lag:
y = y ./ sqrt(auto_a(len) .* auto_b(len)); 



%====== cross correlation as spectral multiplication ==================
% Doing cross correlation as spectral multiplication. This is
% identical to xcorr when flag='biased'. So this serves just as a 
% test to see if result is identical to method above. Result is
% returned in yy. 
%
% It is necessary to put the fourier-transformed lag channel in 
% its complex conjugate form to get the cross correlation,
% otherwise one does a simple convolution (i.e, spectral
% multiplication without putting lag-channel into complex conjugate 
% form)

if size(a,1) == 1 a = a'; end   % always need a as column vector
if size(b,1) == 1 b = b'; end   % always need b as column vector
A = fft(a, 2.*length(a));  % # of DFT-points has to be twice length of a
B = fft(b, 2.*length(b));  % # of DFT-points has to be twice length of b

AA = A .* conj(A);  % auto-correlation
BB = B .* conj(B);  % auto-correlation
C  = A .* conj(B);  % cross-correlation

% for following 3 lines, imaginary part is (close to) zero anyway:
a2 = real(ifft(AA)); % max value at zero-lag needed for normalization
b2 = real(ifft(BB)); % max value at zero-lag needed for normalization
c2 = real(ifft(C));  

% normalize by zero-time lag values of auto-correlations, which are always max. values:
c2 = c2 ./ sqrt(max(a2) .* max(b2));
                                    
% need to switch halfs of time series: 	
c2 = [c2(length(c2)/2+2:end)', c2(1:length(c2)/2)'];

% need to flip time series left-right:
yy = fliplr(c2);



%=============== determine confidence intervals in corr. coef. ================
% To determine confidence intervals use the spectral
% cross-correlation method. Here, one of the channels (does not
% matter which (but can't be both) has its phases randomly changed
% over a range of 2pi (has to be from -pi to pi in Matlab). This
% way the auto-correlation is kept unchanged (internal structure is 
% unchanged). If both channels' phases were randomly changed, the
% result for cross-corr. would always be the same (i.e., the result 
% for 2 random time series).


if exist('rep')==0
  bdl = NaN;
  bdu = NaN;
else  
  if exist('perc')==0 perc=0.9; end %default confidence interval is 90%
  if perc < 0 | perc > 1 error('Confidence interval has to be 0<=perc<=1'); end    
  if rep > 0
    if rep<10 warning('Number of repetitions should be >= 10.'); end
    yyy = [];
    lower = (1-perc)/2;     % e.g. for perc = 0.9 --> lower = 0.05
    upper = 1-((1-perc)/2); % e.g. for perc = 0.9 --> upper = 0.95
    for j=1:rep
      % determine new B with same magnitude but randomly assigned phases
      % that lie between -pi and pi. See MATLAB function "angle" for syntax
      
      new_B = abs(B) .* exp(i*(2*pi.*rand(size(B))-pi));
      
      BB = new_B .* conj(new_B);  % auto-correlation
      C = A .* conj(new_B);       % cross-correlation
      new_b2 = real(ifft(BB));
      c2  = real(ifft(C));
      c2 = c2 ./ sqrt(max(a2) .* max(new_b2));
      c2 = [c2(length(c2)/2 + 2:end)', c2(1:length(c2)/2)'];
      c2 = fliplr(c2);
      yyy = [yyy ; c2]; % each column is a time lag, each row is
	                % a different trial 
    end
    yyy = sort(yyy);   % ascending order in each column (for each time lag)

    lower_index = round(lower*j);
    upper_index = round(upper*j);
    if lower_index==0 lower_index=1; end
    if lower_index>size(yyy,1) lower_index=size(yyy,1); end
    if upper_index==0 upper_index=1; end
    if upper_index>size(yyy,1) upper_index=size(yyy,1); end
    
    bdl = yyy(lower_index,:)';
    bdu = yyy(upper_index,:)';

    if size(y,1) == 1 
      bdl = bdl'; 
      bdu = bdu';
    end
  end
end
