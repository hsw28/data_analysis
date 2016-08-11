function [c,ww] = gh_smooth(varargin)

if((nargin == 3) && strcmp(varargin{3},'gauss')) 

    sd = varargin{2};
    pct_mass = 0.95;
    z_score = icdf('normal',pct_mass,0,sd);
    

else
    
    disp(sprintf('Call to gh_smooth just got passed to smooth.  Use arg3 \''gauss\'', arg2 sd'));
    [c,ww] = smooth(varargin{:});
   
    
    
end