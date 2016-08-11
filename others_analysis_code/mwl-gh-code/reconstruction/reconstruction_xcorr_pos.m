function [xcorr_matrix, peak_offset_matrix] = reconstruction_xcorr_pos(r_pos_array, varargin)

% xcorr_matrix = RECONSTRUCTION_XCORR_POS() computes the cross correlations
% among all pairs of r_pos in an r_pos array, shifting in the up/down
% (position) direction, as opposed to shifting in time
%
% returns [xcorr_matrix, and peak_offset_matrix] 
% -xcorr_matrix.data is
%  n_r_pos X n_r_pos X n_pos_shifts, row identity isthe first arg to xcorr
%  and column identity is the second; third dimension is the r value
%  xcorr_matrix.lags is the vector of lag amounts (the z-axis labels
%  for xcorr_matrix.data)
% -peak_offset_matrix is the list of optimal position shifts for each pair
%  of r_pos's.
% 
% reading peak_offset_matrix(x,y), given pdf x and y, x leads y by how much

p = inputParser();
p.addParamValue('max_lag_meters',0.5);
p.addParamValue('r_pos_use_indices',[]);
p.addParamValue('xcorr_norm','unbiased');
p.addParamValue('post_norm',true);
p.addParamValue('n_drop_edge_lags', 4);
p.parse(varargin{:});
opt = p.Results;

% figure out the shift amounts
dx = r_pos_array(1).x_vals(2) - r_pos_array(1).x_vals(1);
% round max_lag down to the nearest dx
max_lag_samps = floor( opt.max_lag_meters / dx );

if(isempty(opt.max_lag_meters))
    % figure it out with a test run of one timebin
    c = xcorr(r_pos_array(1).pdf_by_t(:,1));
    max_lag_samps = (numel(c)-1)/2;
    % according to help xcorr, this should be size(pdf_by_t,1) - 1
end

xcorr_matrix.lags = ((-1*max_lag_samps):max_lag_samps) .* dx;
n_lags = numel(xcorr_matrix.lags);

% use every index if no index for use was passed in
if(isempty(opt.r_pos_use_indices))
    opt.r_pos_use_indices = ones(1, size(r_pos_array(1).pdf_by_t,2) );
end

n_pos = size(r_pos_array(1).pdf_by_t,1);
n_ts  = sum(opt.r_pos_use_indices);
n_pdf = numel(r_pos_array);

% collect the data together
pdf_data = zeros( n_pos, n_ts, n_pdf );
              
for n = 1:numel(r_pos_array)
    pdf_data(:,:,n) = r_pos_array(n).pdf_by_t(:,opt.r_pos_use_indices);
end

xcorr_matrix.data = zeros(n_pdf,n_pdf,n_lags);
peak_offset_matrix = zeros(n_pdf,n_pdf, n_ts);
xcorrs_by_time = zeros(n_lags,n_ts);
zero_lag_ind = xcorr_matrix.lags == 0;

for m = 1:n_pdf
    for n = 1:n_pdf
        disp(['Working on pair m = ', num2str(m), ', n = ', num2str(n)]);
        for t = 1:n_ts
            
            this_xcorr = xcorr(pdf_data(:, t, m), pdf_data(:, t, n), ...
                max_lag_samps, opt.xcorr_norm);
            
            if(opt.post_norm)
                this_xcorr = this_xcorr ./ this_xcorr(zero_lag_ind);
            end
            
            xcorrs_by_time(:,t) = this_xcorr;
            
            peak_offset_matrix(m,n,t) =...
                mean( xcorr_matrix.lags( this_xcorr == max(this_xcorr) ));
            
        end
            
        this_m_and_n_mean_xcorr = mean(xcorrs_by_time, 2);
        xcorr_matrix.data(m,n,:) = ...
            reshape(this_m_and_n_mean_xcorr,[1,1,n_lags]);

    end    
end
            
            
            
            
            
            
        