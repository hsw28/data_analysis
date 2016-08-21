function pdf = parameter_estimation_gauss(tau,tc,ns)

% PARAMETER_ESTIMATION_SIMPLE - Computes pdf for head direction or position.
% 
% pdf = parameter_estimation_simple(tau,tuningcurves,n)
% Given a series of time bins of equal duration tau, this function will
% assign probability values to each of the possible states the encoded
% variable (position or head direction) could take in each time bin. 
% Estimation is based on the activity of m cells using Bayes reconstruction
% method.  
% The inputs to this function are: 
% tau - duration of individual time bins, in seconds. 
% tuningcurves - receptive fields of the (m) recorded cells. This matrix
% has  b rows, representing the number of spatial bins, and m columns,
% representing the number of recorded cells. 
% n - observed number of spikes per cell per time bin. This matrix has m
% rows reflecting the number of recorded cells and t columns corresponding
% to the number of time bins.


% Transform count variable from an m-by-t matrix to an 1-by-m-by-t matrix. 
% The transformed variable can be thought of as a plane whose x and y
% coordinates equal the number of recorded cells and the number of time
% bins, respectively. 


% Alter the spike counts from counts to sqrt(counts), so I can use the
% gaussian aproximation
ns = sqrt(ns);
var = .25;

pos_bin = size(tc,1);
n_cell = size(tc,2);


tc = tc(:,:,1);

scale_const = (.5 * pi) ^ (-n_cell/2) * exp(n_cell*2);

size(tc)
size(ns)
ns = repmat(ns, 1, size(tc,2));
est_sum = sum( (sqrt(ns) - sqrt(tc)).^2);

pdf = scale_const * exp(est_sum);


%%
% 
% n = reshape(ns,[1 size(ns)]);
% % Compute different elements of Bayes formula
% sum_tc = sum(tuningcurves,2);
% exp_factor = exp(-tau*sum_tc);
% xybin = size(tuningcurves,1);
% cells = size(tuningcurves,2);
% tbins = size(n,3);
% 
% % Transform matrices to make element by element operations possible (avoid
% % for loops). 
% tc = repmat(tuningcurves,[1 1 tbins]);
% exp_FAC = repmat(exp_factor,1,tbins);
% N = repmat(n,[xybin 1 1]);
% power_tc = tc.^N;
% prod_power_tc = reshape(prod(power_tc,2),xybin,tbins);
% % Put all elements together to get unnormalized PDF
% pdfnorm = prod_power_tc.*exp_FAC;
% 
% % Determine which time bins have no spiking activity to set their pdfs to
% % zero.  Count number of spikes per time bin irrespective of cell identity
% sumns = sum(ns,1);
% % Identify and index time bins with no activity
% noact = sumns == 0;
% % Set pdf values to zero for time bins with no activity
% pdfnorm(:,noact) = 0;
% % Calculate normalization factors
% norm = sum(pdfnorm,1);
% % Add a small number to normalizing factor to avoid "divide by zero
% % warning"
% Norm = repmat(norm+eps,[xybin,1]);
% pdf1 = pdfnorm./Norm;
% no_prob = sum(pdf1)==0;
% 
% pdf1(:,no_prob) = 1/size(pdf1,1);
% 
