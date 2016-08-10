function fn = mkfun_ripple_phase_wrt_trode_location(varargin)

p = inputParser();
p.addParamValue('env_i_thresh',0.1);
p.addParamValue('env_j_thresh',0);
p.addParamValue('env_units','mv');
p.addParamValue('n_bins',40);


fn = @(d,i,j,o) ripple_phase_wrt_trode_location(d,i,j,o);