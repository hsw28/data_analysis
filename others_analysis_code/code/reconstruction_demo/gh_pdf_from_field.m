function [pdf_array, pdf_prod] = gh_pdf_from_field(sdat,varargin)

p=inputParser();
p.addParamValue('tau',0.2,@isreal);
p.addParamValue('counts',[0:20],@(x) all(isreal(x)));
p.addParamValue('plot_pdfs',true)
p.addParamValue('plot_pdf_prod',false)
p.addParamValue('run_direction','outbound');
p.addParamValue('normalize_within_count',false);
p.addParamValue('test_count_vector',[]);
p.parse(varargin{:});

n_pdf = numel(sdat.clust);
n_pos = numel(sdat.clust{1}.field.bin_centers);
counts = p.Results.counts;
n_counts = numel(counts);
pdf_array = zeros([n_counts,n_pos,n_pdf]);
expected_count_array = zeros(n_pdf,n_pos);

for n = 1:n_pdf
    if(strcmp(p.Results.run_direction,'outbound'))
        rate = sdat.clust{n}.field.out_rate;
    elseif(strcmp(p.Results.run_direction,'inbound'))
        rate = sdat.clust{n}.field.in_rate;
    elseif(strcmp(p.Results.run_direction,'bidirect'))
        rate = sdat.clust{n}.field.bidirect_rate;
    else
        warning(['Could not use the run_direction, ', p.Results.run_direction,'. Using indound.']);
        rate = sdat.clust{n}.field.out_rate;
    end
    if(any(isnan(rate)))
        warning('Found NaNs in field rates.  Converting to zeros');
        rate(isnan(rate)) = 0;
    end
    
    expected_count_array(n,:) = rate .* p.Results.tau; % this is the poisson lambda parameter
    expected_count = reshape(expected_count_array(n,:),1,[]);
    expected_count = repmat(expected_count,n_counts,1);
    this_counts = reshape(counts,[],1); % this is the k parameter (counts RV)
    this_counts = repmat(this_counts,1,n_pos);
    
    %disp(['Size expected_count: ', num2str(size(expected_count)),' .  Size this_counts:', num2str(size(this_counts))]);
    this_array = exp(-1.*expected_count) .* (expected_count .^ this_counts) ./ factorial(this_counts);
    %disp(['Size this_array:', num2str(size(this_array)), ' .  Size slice:', num2str(size(pdf_array(:,:,n)))]);
    pdf_array(:,:,n) = this_array;
    if(p.Results.normalize_within_count)
        sum_vector = sum(this_array,2);
        sum_array = repmat(sum_vector,1,n_pos);
        pdf_array(:,:,n) = this_array ./ sum_array;
    end
end

pdf_prod = prod(pdf_array,3);

if(p.Results.plot_pdfs)
   n_plots = n_pdf;
   if(p.Results.plot_pdf_prod)
       n_plots = n_plots+1;
   end
   for n = 1:n_pdf
       subplot(1,n_plots,n);
       im = (1-pdf_array(:,:,n)).*100;
       image(sdat.clust{1}.field.bin_centers([1,n_pos]),counts([1,n_counts]),(im.^1));
       colormap(hot(100));
       set(gca,'YDir','normal');
       hold on
       plot(sdat.clust{1}.field.bin_centers,expected_count_array(n,:),'b','LineWidth',2);
   end
   if(p.Results.plot_pdf_prod)
       subplot(1,n_plots,n_plots);
       image(sdat.clust{1}.field.bin_centers([1,n_pos]),counts([1,n_counts]),pdf_prod);
   end
    
elseif(p.Results.plot_pdf_prod)
    
end

if(not(isempty(p.Results.test_count_vector)))
    if(not(p.Results.normalize_within_count))
        warning('Test vector reconstruction should only be used with within-count normalization');
    end
    figure;
    test_count_vector = p.Results.test_count_vector;
    test_count_index = zeros(size(test_count_vector));
    p_given_c_array = zeros(n_pdf,n_pos);
    for n = 1:numel(test_count_vector)
        test_count_index(n) = find(test_count_vector(n) == p.Results.counts);
        p_given_c_array(n,:) = pdf_array(test_count_index(n),:,n);
    end
    r_pos = prod(p_given_c_array,1);
    r_pos = r_pos ./ (sum(r_pos))
    im = (1-r_pos)*100;
    image(sdat.clust{1}.field.bin_centers([1,n_pos]),[0 1],im);
    colormap(hot(60));
    hold on
    plot(sdat.clust{1}.field.bin_centers,r_pos,'LineWidth',2);
    set(gca,'YDir','normal');
    ylim([0 1]);
end
    