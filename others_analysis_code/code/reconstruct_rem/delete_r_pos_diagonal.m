function r_pos_array = delete_r_pos_diagonal(r_pos_array)
% DELETE_R_POS_DIAGONAL - zeroes reconstruction matrix along diagonal

if(isempty(r_pos_array))
    % then test
    x = [0 1 2 3 4];
    t = [0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5];
    x_range = [0 4];
    t_range = [0 5];
else
    x_range = [r_pos_array(1).x_range(1), r_pos_array(1).x_range(2)];
    t_range = [r_pos_array(1).tstart,r_pos_array(1).tend];
    x = linspace(x_range(1),x_range(2),size(r_pos_array.pdf_by_t,2));
    t = linspace(t_range(1),t_range(2),size(r_pos_array.pdf_by_t,1));
    %x_range = 1:size(r_pos_array(1).pdf_by_t,2);
    %t_range = 1:size(r_pos_array(1).pdf_by_t,1);
end

[tt,xx] = meshgrid(t,x);
diff_mat = abs(xx-tt);

keep_mat = ~(diff_mat == repmat(min(diff_mat),length(x),1));
keep_mat = diff_mat > 0.5;

keep_mat(1:end-1,:) = min( keep_mat(1:end-1, :), keep_mat(2:end,:) );

keep_mat(2:end,:)   = min( keep_mat(1:end-1, :), keep_mat(2:end,:) );

%imagesc(keep_mat)

if(~isempty(r_pos_array))
    for n = 1:length(r_pos_array)
        this_pdf = r_pos_array(n).pdf_by_t;
        this_pdf(~logical(keep_mat')) = 0;
        this_pdf = this_pdf ./ repmat(sum(this_pdf,1),length(t),1);
        r_pos_array(n).pdf_by_t = this_pdf;
    end
end