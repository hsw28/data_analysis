function mv = ad2uv(waveform, gain)
%   nv = AD2MV(signal, gains)
%   Converts from AD units to millivolts.
%   signal and gains must be the same size
    

 if size(gain,2) == size(waveform,1)
        gain = gain';
 end

 mv = zeros(size(waveform));
 for i = 1:size(waveform,3)
 
    % correct for 0 gains
  
    is_zero = (gain==0);
    waveform(is_zero)=0;
    gain(is_zero)=Inf;
   
    tmp = squeeze( double(waveform(:,:,i))./2048 .* 10 .* 1e6 );
    
    mv(:,:,i) = bsxfun(@rdivide, tmp, gain);
 end
    
end
