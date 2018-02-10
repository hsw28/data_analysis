function f = spikespectra2(cluster, tm)

st = spiketrain(cluster, tm);

k = 1;
sam = 20000; % number of samples per bin
stbin = zeros(sam, ceil(length(st)/sam)-1);
while k<=ceil((length(st)/sam)-1)
    q = st(((k-1)*(sam)+1):k*sam);
    stbin(:,k) = q';
    k = k+1;
end;

Fs = 2000; %data sampling rate
%s = size(s); %length of object that holds LS events
s = size(stbin, 2);
figure
transforms = zeros(2549,1); %empty vector to hold FFT sequences
for i = 2:s(1)
    %data = f{i,2}; %current event to transform
    data = stbin(:,i);
    avg = mean(data);
    data = data - avg; %remove DC offset
    L = 5096;
    Y = fft(data,L); %take 5096 point DFT
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    transforms = transforms + P1; %accumulate transform
end
freq = Fs*(0:(L/2))/L; %generate frequency axis
transforms = transforms/(s(1)-1); %average transforms
avg_transform = [freq',transforms];
plot(freq,transforms); %plot average frequency response of LS events
