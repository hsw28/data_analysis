function f = period(signal);

%{
When you talk about computing the frequency of a signal, you probably aren't so interested in the component sine waves. This is what the FFT gives you. 

What you are probably more interested in is the periodicity of the signal. That is, the interval at which the signal becomes most like itself. So most likely what you want is the autocorrelation. This will essentially give you a measure of how self-similar the signal is to itself after being shifted over by a certain amount. So if you find a peak in the autocorrelation, that would indicate that the signal matches up well with itself when shifted over that amount.

1) Window the signal, using a smooth window (a cosine will do. The window should be at least twice as large as the largest period you want to detect. 3 times as large will give better results). (see http://zone.ni.com/devzone/cda/tut/p/id/4844 if you are confused).

2) Take the FFT (however, make sure the FFT size is twice as big as the window, with the second half being padded with zeroes. If the FFT size is only the size of the window, you will effectively be taking the circular autocorrelation, which is not what you want. see https://secure.wikimedia.org/wikipedia/en/wiki/Discrete_Fourier_transform#Circular_convolution_theorem_and_cross-correlation_theorem )

3) Replace all coefficients of the FFT with their square value (real^2+imag^2). This is effectively taking the autocorrelation.

4) Take the iFFT

5) Find the largest peak in the iFFT. This is the strongest periodicity of the waveform. You can actually be a little more clever in which peak you pick, but for most purposes this should be enough. To find the frequency, you just take f=1/T.
%}



