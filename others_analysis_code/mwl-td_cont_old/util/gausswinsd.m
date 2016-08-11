function window = gausswinsd(sd, Fs, ndevs)

if nargin<2
    help(mfilename)
    return
end

if nargin<3
  ndevs = 4;
end

if nargin<2
    Fs = 1;
end

npoints = round( ndevs.*sd.*Fs );
window = normpdf( linspace( -ndevs*sd, ndevs*sd, 2*npoints+1 )', 0, sd );

window = window ./ sum(window);
