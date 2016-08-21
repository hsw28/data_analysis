function varargout = psdmat( x, fs, nfft, window, overlap )

if nargin<2 || isempty(fs)
    fs = 1;
end
if nargin<3 || isempty(nfft)
    nfft = 256;
end
if nargin<4 || isempty(window)
    window = hanning(nfft);
end
if nargin<5 || isempty(overlap)
    overlap = 0;
end

nchan = size(x,2);

if nargout<1
    h = axismatrix( nchan, 1, 'YSpacing', 0.01 );
    set(h(1:end-1), 'XTick', []);
end

for k=1:nchan
    
    [p(:,k) f] = pwelch( x(:,k), window, overlap, nfft, fs );
    
    if nargout<1
        line( f, p(:,k), 'Parent', h(k) );
    end
    
end

if nargout>0
    varargout{1} = p;
end
if nargout>1
    varargout{2} = f;
end