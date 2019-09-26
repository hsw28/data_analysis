function x = Hcorr(one, two);

%finds the normalized cross correlation for two things and puts them into a vector, and outputs a normalized graph. Quick and easy!
%
% remember to smooth and square your lfp and square you acceleration!
% ex: corr(dataone, datatwo)
%
% outputs [correlation; lag]

onenorm = one-mean(one);
twonorm = two-mean(two);

[cor, lag] = xcorr(onenorm, twonorm, 'coeff');

lag = (lag)./30;
%plot(lag./2, cor)
plot(lag, cor)

size(cor);
size(lag);
ylabel('Correlation')
xlabel('Lag (Sec.)')
x = [cor; lag];
