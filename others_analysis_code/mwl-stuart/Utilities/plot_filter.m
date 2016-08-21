function [h w ] = plot_filter(filt, fs, varargin)
% [h w] = plot_filter(filter, fs)
% [h w] = plot_filter(...., axes);
%
%   this is adapted from freqz.m it provides similar functionality but
%   only for FIR filters. Additional functionality includes the option to 
%   plot the filter's frequency response to an specificed axes

if numel(varargin)>0
    a = varargin{1};
    varargin = varargin(2:end);
else
    figure('Position',   [200 500 1000 350]);
    a = axes;
end;




options = freqz_options(varargin{:});

[h w] = firfreqz(filt, options);


plot(w*fs/(2*pi), log(abs(h))*10);
xlabel('Frequency (Hz)');
ylabel('Magnitude dB');
set(a, 'XGrid', 'on', 'YGrid', 'on');




    function [h,w,options] = firfreqz(b,options)

    % Make b a row
    b = b(:).';
    n  = length(b); 

    w      = options.w;   
    Fs     = options.Fs;
    nfft   = options.nfft;
    fvflag = options.fvflag;

    % Actual Frequency Response Computation 
    if fvflag,
       %   Frequency vector specified.  Use Horner's method of polynomial
       %   evaluation at the frequency points and divide the numerator
       %   by the denominator.
       %
       %   Note: we use positive i here because of the relationship
       %            polyval(a,exp(i*w)) = fft(a).*exp(i*w*(length(a)-1))
       %               ( assuming w = 2*pi*(0:length(a)-1)/length(a) )
       %        
       if ~isempty(Fs), % Fs was specified, freq. vector is in Hz
          digw = 2.*pi.*w./Fs; % Convert from Hz to rad/sample for computational purposes
       else
          digw = w;
       end

       s = exp(1i*digw); % Digital frequency must be used for this calculation
       h = polyval(b,s)./exp(1i*digw*(n-1));
    else   
       % freqvector not specified, use nfft and RANGE in calculation
       s = find(strncmpi(options.range, {'twosided','onesided'}, length(options.range)));

       if s*nfft < n,
          % Data is larger than FFT points, wrap modulo s*nfft      
          b = datawrap(b,s.*nfft);   
       end  

       % dividenowarn temporarily shuts off warnings to avoid "Divide by zero"
       h = fft(b,s.*nfft).';
       % When RANGE = 'half', we computed a 2*nfft point FFT, now we take half the result
       h = h(1:nfft);
       h = h(:); % Make it a column only when nfft is given (backwards comp.)
       w = freqz_freqvec(nfft, Fs, s);
       w = w(:); % Make it a column only when nfft is given (backwards comp.)
    end

    end

    function [options,msg] = freqz_options(varargin)
    %FREQZ_OPTIONS   Parse the optional arguments to FREQZ.
    %   FREQZ_OPTIONS returns a structure with the following fields:
    %   options.nfft         - number of freq. points to be used in the computation
    %   options.fvflag       - Flag indicating whether nfft was specified or a vector was given
    %   options.w            - frequency vector (empty if nfft is specified)
    %   options.Fs           - Sampling frequency (empty if no Fs specified)
    %   options.range        - 'half' = [0, Nyquist); 'whole' = [0, 2*Nyquist)


    % Set up defaults
    options.nfft   = 2048;
    options.Fs     = [];
    options.w      = [];
    options.range  = 'onesided';
    options.fvflag = 0;
    isreal_x       = []; % Not applicable to freqz

    [options,msg] = psdoptions(isreal_x,options,varargin{:});

    if any(size(options.nfft)>1), 
       % frequency vector given, may be linear or angular frequency
       options.w = options.nfft;
       options.fvflag = 1;
    end
    end

end