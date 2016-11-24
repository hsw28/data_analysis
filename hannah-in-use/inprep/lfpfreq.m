function avg_transform = lfpfreq(LS_lfp_data)

% takes LS LFP and finds power spectrum. does NOT filter in any way
% findFrequencies(LS.data);

f = LS_lfp_data;

Fs = 2000; %data sampling rate
figure

avg = mean(f); 
data = f - avg; %remove DC offset
L = 5096;
Y = fft(data,L); %take 5096 point DFT
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
transforms = P1; %accumulate transform

freq = Fs*(0:(L/2))/L; %generate frequency axis

avg_transform = [freq',transforms];
plot(freq,transforms); %plot average frequency response of LS events
