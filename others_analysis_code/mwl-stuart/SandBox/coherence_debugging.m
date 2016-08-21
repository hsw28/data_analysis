% a = ripBase;
% 
% figure;
% for i = 1:nRipple
%     x = ripBase(i,:);
%     plot(x);
%     pause;
% end

nSample = 601;

nfft = 2^nextpow2(601);

x = ripBase(34,:);


x2 = fft(x);
x3 = ifft(x2);

plot(1:601, x, 1:601, log(abs(x2)) * 60, 1:601, x3)

%%

b = reshape( ripBase', nRipple * nSample, 1);
s1 = reshape( ripShuf1', nRipple * nSample, 1);
s2 = reshape( ripShuf2', nRipple * nSample, 1);

nfft = nSample;
nOverlap = 0;
fs = data(1).fs;

 k = hanning(nfft);
% k = hamming(nfft);
% k = ones(nfft,1);

tic;
[c] = mscohere(b, s1, k, nOverlap, nfft, fs);
toc;
% [c f] = mscohere(ripBase(1,:), ripShuf1(1,:), 601, nOverlap, nfft, fs);

if exist('f', 'var')
    if ishandle(f)
        close f
    end
end
f = figure;
plot(c);