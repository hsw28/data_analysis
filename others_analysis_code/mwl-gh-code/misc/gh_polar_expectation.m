function E = gh_polar_expectation(theta, rho)
% E = gh_polar_expectation(theta,rho) calculate expectation of polar random variable
% theta - vector of angles (x axis of PDF)
% rho    - array of measurements, size( numel(theta), number_of_series)
% Output E is size 1 by number_of_series

theta = reshape(theta, [], 1);

if( ~( size(theta,1) == size(rho, 1)))
    error('gh_polar_expectation:theta_rho_size_mismatch',...
        ['theta (size: ', num2str(size(theta)), ' )   rho (size: ',...
        num2str(size(rho)), ') mismatch.']);
end

if(~( numel(theta) == numel(unique(mod(theta, 2*pi)))))
    error('gh_polar_expectation:nonunique_thetas',...
        'There are non-unique thetas in the input.  Did you have both pi and -pi?  Those are the same theta');
end

n_series = size(rho,2);
n_x = numel(theta);

theta_big = repmat(theta,1,n_series);

%rho_sum = sum(rho,1);
%rho_norm = rho ./ repmat(rho, n_x, 1);

rho_i = rho .* cos(theta_big) + i .* rho .* sin(theta_big);

E = angle( sum( rho_i, 1) );