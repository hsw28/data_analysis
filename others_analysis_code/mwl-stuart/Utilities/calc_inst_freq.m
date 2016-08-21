function f = calc_inst_freq(v, fs)

% compute the unwrapped phase of the signal
phase = unwrap( angle( hilbert( v ) ) );
dPhase = gradient(phase);

% correct for points when the dPhase is negative
invalidPts = dPhase < 0;
invalidPts = cumsum(invalidPts);

phaseCorrected = phase + invalidPts*2*pi;

% compute the unwrapped phase of the signal
dPhase = gradient(phaseCorrected);

f = fs .* dPhase ./ (2*pi);

% remove frequency estimates thare are outside of the ripple band
f (f > 300 | f<100) = nan;

end