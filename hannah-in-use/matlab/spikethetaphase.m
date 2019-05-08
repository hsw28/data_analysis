function f = spikethetaphase(cluster, lfp, time)
  [time,ia,ic] = unique(time);
  lfp = lfp(ia);

lfp = thetafilt412(lfp);
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
