function ff = spikespectra(cluster, tm)

  %takes cluster data, seperates into 1sec and then uses a tool from chronux to determine spiking frequency spectra

st = spiketrain(tm, cluster);
%group into 2000 samples each for 1 sec window
k = 1;
stbin = zeros(2000, ceil(length(st)/2000)-1);
while k<=ceil((length(st)/2000)-1)
    stbin(:, k) = st(((k-1)*(2000)+1):k*2000);
    k = k+1;
end;


% for frequency resolution of .5hz using 2sec window
TW =  1; %time bandwidth product
ntapers = 2*TW-1; %number of tapers
params.Fs = 2000; %sampling frequency
params.tapers = [TW,ntapers]; %time-band product, no. of ntapers
params.fpass = [0 100]; %frequency range to examine
params.trialave = 1; %perform trial average

%compute coherence
[cr, f] = mtspectrumpb(stbin(:,:), params');

figure
plot(f, cr)
ylabel('Power [Hz]')
xlabel('Frequency [Hz]')
