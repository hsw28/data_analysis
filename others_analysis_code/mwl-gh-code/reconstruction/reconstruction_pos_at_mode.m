function pos_at_mode = reconstruction_pos_at_mode(r_pos_array)

n_pdf = numel(r_pos_array);
n_ts = size(r_pos_array(1).pdf_by_t,2);
n_pos = size(r_pos_array(1).pdf_by_t,1);

pos_vals = r_pos_array(1).x_vals;
big_pos_vals = repmat(pos_vals,1,n_ts);

pos_at_mode = zeros(n_pdf, n_ts);

for n = 1:n_pdf
    % make an array that zeros all points in the pdf_by_t at which
    % the pdf value doesn't match that column's max and 1's all elemets 
    % that do
    save_p_at_m = repmat(max(r_pos_array(n).pdf_by_t,[],1),n_pos,1) == ...
        r_pos_array(n).pdf_by_t;
    
    % use that matrix of saved mode positions as a mask on big_pos_vals
    % and take the max pos val in each column as the pos corresponding
    % to that time's mode position
    pos_at_mode(n,:) = max( (big_pos_vals .* save_p_at_m) , [], 1);
    
    r_pos_array(n).pos_at_mode = pos_at_mode(n,:);
end