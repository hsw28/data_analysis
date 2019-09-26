function [kappa meanphase circdev] = spikethetaphase(cluster, lfp, time, filt, varargin)
  %returns kappa DOES NOT NORMALIZE FOR HPC PHASE
  %for LFP put 1 if already filtered, 0 if need to filter 4-12, 812 if theta812, 47 if theta4-7
  %defaults to reducing to 2pi. if you want different numner of pi put the number in varargin (eg 4)

if length(varargin)<1
  varargin = 2;
elseif length(varargin)==1
  varargin = cell2mat(varargin(1));
end


  [time,ia,ic] = unique(time);
  lfp = lfp(ia);

if filt==0
lfp = thetafilt412(lfp);
elseif filt ==812
lfp = theta812(lfp);
elseif filt ==47
lfp = theta47(lfp);
end

f = lfp;
hilly = hilbert(lfp);
f = hilly;


theta_phase = interp1(time(1:length(hilly)), unwrap(angle(hilly)), cluster);
rad = limit2pi(theta_phase, [0 varargin*pi]);
rad = rad(~isnan(rad));

meanphase = rad2deg(limit2pi(circ_mean(rad)));
circdev = rad2deg(circ_std(rad));

phases = [meanphase; circdev];


%theta_phase = theta_phase(~isnan(theta_phase));



  if length(rad)>1
    kappa = circ_kappa(rad);
    [p z] = circ_rtest(rad);

  else
    kappa = NaN;
  end
