function [pdf, tbins, spike_counts] = reconstruct(ts, te, tc, cells, varargin)
 
    args.t_var = 'time';
    
    args.tau = .25;
    args.percent_overlap = 0;
    args.max_pdf_matrix_size = 50000;
    args.max_pdf_comp_size = floor(args.max_pdf_matrix_size / size(tc,1));
    args.smooth = 0;
    args.kernel = [.9 .4 .1 .05];
    
    args = parseArgsLite(varargin, args);
    
    tbins = get_tbins(ts, te, args.tau, args.percent_overlap);

    tTmp = [tbins(:,1); tbins(end,1) + args.tau];
   
    spike_counts= zeros(length(cells), length(tbins));
    
    for i=1:numel(cells)
        
        sc = histc(cells(i).(args.t_var), tTmp);
        spike_counts(i,:) = sc(1:end-1);
%         spike_counts(i,:) = sortedhist(cells(i).(args.t_var), tbins);
%         spike_counts(i,:) = histc(cells(i).(args.t_var), tbins(:,1) );
    end
    
    if args.smooth
        spike_counts = smoothn(spike_counts, 'kernel', 'my_kernel', 'my_kernel', args.kernel);
    end
    
    n_dir = size(tc,3);
    pdf = nan(size(tc,1), length(tbins), n_dir);
    
    tc = combine_tc(tc);
    %for dir = 1:n_dir
        if size(spike_counts,2)>args.max_pdf_comp_size
            n_section = ceil(size(spike_counts,2)/args.max_pdf_comp_size);
            %disp(['Requested PDF is too big, cutting into ', num2str(n_section), ' sections']);
            for i=0:n_section-1
                istart = i*args.max_pdf_comp_size+1;
                iend = min([(i+1)*args.max_pdf_comp_size, size(spike_counts,2)]);
                pdf_short = parameter_estimation_simple(args.tau, tc, spike_counts(:,istart:iend));

                switch i
                    case 0
                        pdf_temp = pdf_short;
                    otherwise
                        pdf_temp = [pdf_temp pdf_short]; %#ok
                end
            end
        else
            %pdf_temp = parameter_estimation_simple(args.tau, tc(:,:,dir), spike_counts);
            pdf_temp = parameter_estimation_simple(args.tau, tc, spike_counts);
        end 
        %pdf(:,:,dir) = pdf_temp;
        pdf = pdf_temp;
    %end
    
end


function tbins = get_tbins(ts, te, tau, percent_overlap)    
    dt = tau * (1-percent_overlap);
    tbins = ts:(tau*(1-percent_overlap)):te;
    
    if numel(tbins)==1
        tbins = [tbins, tbins+tau];
    end
    
    tbins = [tbins', tbins'+tau];
end

function tc_n = combine_tc(tc)
tc_n = [];
for i=1:size(tc,3)
    tc_n = [tc_n; tc(:,:,i)];
end
        

end