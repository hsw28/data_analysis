function p_at_mode = reconstruction_p_at_mode(r_pos_array)

n_pdf = numel(r_pos_array);
n_ts = size(r_pos_array(1).pdf_by_t,2);
n_pos = size(r_pos_array(1).pdf_by_t,1);

pos_vals = r_pos_array(1).x_vals;
big_pos_vals = repmat(pos_vals,1,n_ts);

p_at_mode = zeros(n_pdf, n_ts);

for n = 1:n_pdf
    p_at_mode(n,:) = max(r_pos_array(n).pdf_by_t,[],1);
end