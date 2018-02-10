function ff = spikespectra(cluster, tm)

  %takes cluster data, seperates into 1sec and then uses a tool from chronux to determine spiking frequency spectra
st = spiketrain(cluster, tm);


%group into 10000 samples each for 5 sec window
k = 1;
sam = 20000; % number of samples per bin
stbin = zeros(sam, ceil(length(st)/sam)-1);
while k<=ceil((length(st)/sam)-1)
    q = st(((k-1)*(sam)+1):k*sam);
    stbin(:,k) = q';
    k = k+1;
end;


% for frequency resolution of 1hz using 5sec window

  TW = (sam/2000)*2; %time bandwidth product
  ntapers = 2*TW-1; %number of tapers
  params.Fs = 2000; %sampling frequency
  params.tapers = [TW,ntapers]; %time-band product, no. of ntapers
  params.fpass = [1 500]; %frequency range to examine
  params.trialave = 1; %perform trial average

  %compute coherence
  [cr, fr] = mtspectrumpb(stbin, params');
  fr = fr;
  sumcr = cr+cr;

figure
plot(fr, cr)
ylabel('Power [Hz]')
xlabel('Frequency [Hz]')
