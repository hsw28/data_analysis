function eeg_spectra( rootdir, epoch, spectrogram)

if nargin<2
  help(mfilename)
  return
end

if nargin<3
  spectrogram=0;
end
  
e = import_eeg(rootdir, epoch);
n = numel(e);

if ~spectrogram

  h = axismatrix( 1,n );

  maxval = -Inf;
  
  for k=1:n
    
    data = e(k).load();
    nfft = 2.^(ceil(log2(e(k).rate)));
    [p, f] = pwelch( double(data), hanning(nfft), 0, nfft, e(k).rate);
    
    plot( h(k), f, p );
    
    maxval = max( max(p), maxval );
    
  end
  
  set( h, 'YLim', [0 maxval]);
  
else
  
  h = axismatrix( n,1 );

  for k=1:n
    
    [data,time] = e(k).load();
    nfft = 2.^(ceil(log2(e(k).rate)));
    [b,f,t] = specgram(double(data), nfft, e(k).rate, hanning(nfft), 0.5*nfft);
    
    imagesc( t+time(1),f, abs(b) ,'Parent', h(k));
    
  end  
  
  linkprop(h, 'CLim');
  
end


linkaxes( h, 'xy' );

