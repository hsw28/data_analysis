function entropy_matrix = reconstruction_entropy(r_pos_array)

% RECONSTRUCTION_ENTROPY computes the entropy timecourse in position
% reconstructions

n_pdf = numel(r_pos_array);
n_ts = size(r_pos_array(1).pdf_by_t,2);
n_pos = size(r_pos_array(1).pdf_by_t,1);

entropy_matrix = zeros(n_pdf,n_ts);

for n = 1:n_pdf
    this_pdf = r_pos_array(n).pdf_by_t;
    entropy_matrix(n,:) = -1 .* sum(this_pdf .* log2(this_pdf), 1);
    r_pos_array(n).entropy = entropy_matrix(n,:);
end

