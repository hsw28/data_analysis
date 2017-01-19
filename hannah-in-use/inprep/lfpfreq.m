function avg_transform = lfpfreq(LS_lfp_data)

% takes LS LFP and finds power spectrum. does NOT filter in any way
% findFrequencies(LS.data);

samples = LS_lfp_data;

L = 11000;
Q = length(samples);
M = Q;

% estimate the auto correlation matrix
X = fft(samples,2*M-1);
clear('samples');
X = X.*conj(X);
g = ifft(X,2*M-1)/M;
clear('X');
r = [g(1,1) g(2:L).'];
negr = [r(1,1) g((0:-1:-(L-2))+(2*M-1)).'];
clear('g');
R = toeplitz(negr,r);%, negr);
clear('r','negr');

% implement filter bank using optimal filter for each frequency
N = L;
b = 1/N;
w = 2*pi*b*(0:N-1)+ b*pi;
a = (exp(1i*w.'*(0:L-1))).';
P = sum(N./((a'/R).*a.'),2);

figure;
plot(2*(0:N-1)/N,20*log10(wrev(abs(P.'))))
xlabel('Frequency (w/pi)');
ylabel('PSD (dB)')
