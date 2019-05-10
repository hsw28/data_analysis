function f = spikethetaphase(cluster, lfp, time, filt)
  %put 1 if already filtered, 0 if need to filter

  [time,ia,ic] = unique(time);
  lfp = lfp(ia);

if filt==0
lfp = thetafilt412(lfp);
end

f = lfp;
hilly = hilbert(lfp);
f = hilly;
theta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), cluster);
theta_phase = theta_phase(~isnan(theta_phase));
rad = limit2pi(theta_phase);
if length(rad)>1
  kappa = circ_kappa(rad);
  [p z] = circ_rtest(rad);
  f = kappa;
else
  f = NaN;
end
