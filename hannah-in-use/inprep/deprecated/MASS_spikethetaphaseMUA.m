function f = MASS_spikethetaphaseMUA(spikestructure, hpcsum, time, vel)


  mintime = vel(2,1);
	maxtime = vel(2,end);
	%[c indexmin] = (min(abs(hpcsum-mintime)));
	%[c indexmax] = (min(abs(hpcsum-maxtime)));
	%hpcsum = hpcsum(indexmin:indexmax);

	%[c indexmin] = (min(abs(time-mintime)));
	%[c indexmax] = (min(abs(time-maxtime)));
	%time = time(indexmin:indexmax);

  hpcsum = spikehisto(hpcsum, time, 25);
  hpcsum = smoothdata(hpcsum, 'gaussian', 4);
  %hpcsum = MUAthetafilt(hpcsum);
  hilly = hilbert(hpcsum);



  spikenames = (fieldnames(spikestructure));
  spikenum = length(spikenames);
  output = {'cluster name'; '# spikes'; 'kappa'; 'rayleigh' };
  previousdate = 0;
  for k = 1:spikenum
          spikename = char(spikenames(k))
          currentcluster = spikestructure.(spikename);
          [c indexmin] = (min(abs(currentcluster-mintime)));
        	[c indexmax] = (min(abs(currentcluster-maxtime)));
        	currentcluster = currentcluster(indexmin:indexmax);

          theta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), currentcluster);
          rad = limit2pi(theta_phase(~isnan(theta_phase)));

          kappa = circ_kappa(rad);
          rayleigh = circ_rtest(rad);

          newdata = {spikename; length(spikestructure.(spikename)); kappa; rayleigh};
          output = horzcat(output, newdata);

if kappa>.2
plot(histcounts(rad2deg(rad), [0:10:360], 'Normalization', 'probability'));
hold on
end



end

f = output';
