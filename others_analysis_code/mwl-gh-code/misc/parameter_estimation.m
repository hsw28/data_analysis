function pdf1 = parameter_estimation(tau,tuningcurves,n,directional)
% PARAMETER_ESTIMATION - Computes pdf for head direction (HD) or position.
% 
% pdf1 = parameter_estimation(tau,tuningcurves,n,directional)
% For a given time window, tau, this function will calculate the
% probability density function for the parameter of interest (HD or 
% position) based on Bayes estimation method. The inputs to this function 
% are the tuning curves of the (m) recorded cells, as well as the observed 
% number of spikes, n, in that time window. The matrix tuningcurves has b 
% rows (representing the number of bins) and m columns (representing the 
% number of recorded cells). The column vector n, has m rows containing the 
% spike count for each of the m cells in the time window. The variable
% directional indicates whether the estimation is for place alone (0) or
% place and running direction (1).
pdf1 = [];
sum_tc = sum(tuningcurves,2);
exp_factor = exp(-tau*sum_tc);
xybin = size(tuningcurves,1);
cells = size(tuningcurves,2);
tbins = size(n,3);

tc = repmat(tuningcurves,[1 1 tbins]);
exp_FAC = repmat(exp_factor,1,tbins);
N = repmat(n,[xybin 1 1]);

power_tc = tc.^N;
prod_power_tc = reshape(prod(power_tc,2),xybin,tbins);

pdfnorm = prod_power_tc.*exp_FAC;
if directional
    pdfd1 = pdfnorm(1:xybin/2,:); 
    pdfd2 = pdfnorm(xybin/2 + 1:end,:); 
    for i = 1:tbins
        norm1(i) = sum(pdfd1(~isnan(pdfd1(:,i)),i,1));
        norm2(i) = sum(pdfd1(~isnan(pdfd2(:,i)),i,1));
        if sum(n(1,:,i)) == 0               % When no spikes are observed
            pdfd1(:,i) = 0; pdfd2(:,i) = 0; % acroos all cells, do not
        end                                 % estimate parameter.
        pdf1(:,i,1) = pdfd1(:,i)/norm1(i);
        pdf1(:,i,2) = pdfd2(:,i)/norm2(i);
    end
else
    norm = sum(pdfnorm,1);
    for i = 1:tbins
        if sum(n(1,:,i)) == 0       % When no spikes are observed across all
            pdfnorm(:,i) = 0;       % cells, do not estimate parameter.
        end
        pdf1(:,i) = pdfnorm(:,i)/norm(i);
    end
end