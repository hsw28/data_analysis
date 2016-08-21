function mv = ad2mv(signal, gain)
%   nv = AD2MV(signal, gains)
%   Converts from AD units to millivolts.
%   signal and gains must be the same size
    

 if size(gain,2) == size(signal,1)
        gain = gain';
 end

 mv = zeros(size(signal));
 for i = 1:size(signal,3)
 
    % correct for 0 gains
  
    is_zero = (gain==0);
    signal(is_zero)=0;
    gain(is_zero)=Inf;
   
    tmp = squeeze( double(signal(:,:,i))./4096 .* 10 .* 1e6 );
    
    mv(:,:,i) = bsxfun(@rdivide, tmp, gain);
 end
    
end
