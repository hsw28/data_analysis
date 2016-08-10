function sdat = gh_fix_sdat_gains(mua,varargin)

p = inputParser();
p.addParamValue('datadir',[]);
p.parse(varargin{:});

      gains = getGains(eegfh)
      a.chans
      gains = gains(a.chans)
      
      % creates a vector of conv factors according to gains
      adunits_to_mv_f = ...
          1/4095 .* ... % ADCrange/ADCunits (-2048 -> +2047)
          20 .* ... % ADCvolts/ADCrange (-10 -> +10)
          1./gains .*... % volts/ADCvolts (vector)
          1000; % mv/volt
      
      % when gain is 0, conversion factor should be 0, not inf
      adunits_to_mv_f(isinf(adunits_to_mv_f)) = 0;
      
      for k = 1:length(a.chans),
        c.data(:,k) = c.data(:,k) .* adunits_to_mv_f(k);
      end