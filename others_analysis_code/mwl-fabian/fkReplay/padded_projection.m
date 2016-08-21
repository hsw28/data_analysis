function radon = padded_projection(estimate, theta, rho, varargin)
%PADDED_PROJECTION

if nargin<1
  help(mfilename)
  return
end

options = struct('pad', 0, 'padmethod', 'mean');

[options, other, radonoptions] = parseArgs(varargin, options);

[tmp, nn] = radon_transform( estimate',...
                               theta,rho,...
                               radonoptions{:}, ...
                               'method', 'slice' );

[npos winL dummy] = size(estimate); %#ok

if options.pad
  switch options.padmethod
   case 'median'
    radon = median( estimate )';
    radon( nn(1):nn(2) ) = tmp{1}(:);
   case 'mean'
    radon = mean( estimate )';
    radon( nn(1):nn(2) ) = tmp{1}(:);
   case 'geomean'
    radon = geomean( estimate )';
    radon( nn(1):nn(2) ) = tmp{1}(:);
   case 'random'
    radon = estimate( unidrnd( npos, [1 winL] ) + (0:(winL-1)).*npos )';
    radon( nn(1):nn(2) ) = tmp{1}(:);
  end
else
  radon = NaN( winL, 1 );
  radon(nn(1):nn(2)) = tmp{1}(:);
end
