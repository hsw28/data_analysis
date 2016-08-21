function [v Z Zs]= shuffle_signal_phase(v)

Z = fft(v);

R = abs(Z);
theta = angle(Z);

theta = randsample(theta, numel(theta) );

Zs = R.*exp( 1i * theta );

v = ifft(Zs);

v = abs(v) .* exp( 1i * angle(v) );


end