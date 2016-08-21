function [rep_dat shuffle_data] = replay_line_detection(exp, varargin)
%REPLAY_LINE_DETECTION runs the line detection algorithm on an experiment
%
% replay_data = REPLAY_LINE_DETECTION(exp) runs the line detection
% algorithm on the entire expirment struct
%
% replay_data = REPLAY_LINE_DETCTION(..., 'epochs', {epoch_list}) runs the
% algorithm on the specified epochs only
%
% replay_data shuffle_data = REPLAY_LINE_DETECTION(..., 'shuffles', [on, off], ...)
% turns shuffles on or off
%
% replay_data shuffle_data = REPLAY_LINE_DETECTION(..., 'n_shuffles', number, ...)
% specifies the number of shuffles to perform
%
%replay_data = REPLAY_LINE_DETECTION(..., 'trigger', trig_type, ...)
% allows the selction of a trigger type, currently only MUB is an option.
%
% replay_data = REPLAY_LINE_DETECTION(..., 'recon_tau', tau, ....) allows
% the selection of which tau to use for reconstruction, by default 20 ms is
% chosen.
% 
% replay_data = REPLAY_LINE_DETECTION(..., 'tc_dir', 0/1/2, ...) using the 
% overall tuning curve (0), direction 1 tuning curve (1) or direction 2 (2)
%
% see also est_line_detect.m line_detection_viewer.m shuffle_counts.m

    args = struct(  'epochs', {exp.epochs},...
                    'shuffles', 'off', ...
                    'n_shuffles', 0, ...
                    'trigger', 'mub', ... 
                    'recon_tau', .020, ...
                    'tc_dir', 0, ...
                    'percent_overlap', 0 );
                
    %warning('N_shuffle set to 10');

    if ~isempty(varargin) 
            args = parseArgs(varargin, args);
    end

    for ep = args.epochs
        e = ep{1};
    
        disp(['Epoch: ', e]);
       % [tc1 tc2] = get_tuning_curves(exp, e);
        
%         switch args.tc_dir
%             case 0
%                 tc = combine_tuning_curves(tc1, tc2);
%             case 1
%                 tc = tc1;
%             case 2
%                 tc = tc2;
%         end
%         
        rep_dat.(e) = [];
        
        trig = get_triggers(exp.(e), args);
       
        tc = get_tuning_curves(exp, e);
        %tc = mean(tc, 3);

        rep_dat.(e).trig = trig;
        entire_pdf.(e) = [];
        for i=1:size(trig,1)
            %[pdf tbins] = calc_replay(exp.(e).clusters, tc, trig(ii,1), trig(ii,2), args.recon_tau);
            [pdf tbins spike_counts] = reconstruct(trig(i,1), trig(i,2), tc, exp.(e).clusters, 'tau', .02, 'percent_overlap', args.percent_overlap);

            %size(tbins)
            pdf = pdf(:,:,1);
            entire_pdf.(e) = [entire_pdf.(e), pdf];
            pbins = 1:size(pdf,1);
            %pdf_sm = smooth_pdf(pdf);
            [sl inter sc] = est_line_detect(tbins(:,1), pbins, pdf, 'kernelwidth', [3 1]);
            rep_dat.(e).inputs(i).pdf = pdf;
            rep_dat.(e).inputs(i).tbins = tbins(:,1);
            rep_dat.(e).inputs(i).pbins = pbins;
            rep_dat.(e).inputs(i).spike_counts = spike_counts;
            rep_dat.(e).slope(i) = sl;
            rep_dat.(e).intercept(i) = inter;
            rep_dat.(e).score(i) = sc;
            %rep_dat.(e).projection(i) = pro;
        end
    
        if strcmp(args.shuffles, 'on')
            shuf_params.tc = tc;
            shuf_params.rtau = args.recon_tau;
            shuffle_data.(e) = do_shuffles(exp.(e), shuf_params, rep_dat.(e), args, entire_pdf.(e), tc);
        end    
    end
end
% function [pdf t_bins ] = calc_replay(clusters, tc, ts, te, r_tau)
% 
%     t_bins = ts:r_tau:te;
%     spike_count= zeros(length(clusters), length(t_bins));
%     for i=1:length(clusters)
%         spike_count(i,:) = histc(clusters(i).time, t_bins);
%     end
%     
%     %tc = tc(:,:,1);
%     pdf = parameter_estimation_simple(r_tau, tc, spike_count);
% 
% end

function trig = get_triggers(epoch_data, args)

    switch args.trigger
        case 'mub'
            trig = epoch_data.multiunit.burst_times;
        case 'ripple'
            error('Ripple Trigger not implemented yet');
        otherwise
            error('Valid trigger not given. Valid choices are: mub, ripple');
    end
end
% 
% function tc =  combine_tuning_curves(tc1, tc2)
%     tc = tc1 + tc2;
%     ind = (tc==0);
%     tc_sum = sum(tc,1);
%     tc_sum = repmat(tc_sum,size(tc,1),1);
%     %tc_ind = repmat(ind,   size(tc,1),1);
%     warning off;
%     tc = tc./tc_sum;
%     warning on;
%     tc(ind) = 0;
% 
% end
% function [tc1 tc2] = get_tuning_curves(exp, e)
%     for i=1:length(exp.(e).clusters)
%         tc1(i,:) = exp.(e).clusters(i).tc1; %#ok
%         tc2(i,:) = exp.(e).clusters(i).tc2; %#ok
%     end;   
% end


%%
% Shuffle Functions

function shuf_dat = do_shuffles(ep_data, params, rep_data, args, mega_pdf, tc)
    n_shuf = args.n_shuffles;
    disp('Doing Shuffles');
    npt = rep_data.inputs;
    %wb = my_waitbar(0);
    clusters = ep_data.clusters;
    for i=1:length(npt)
        disp([num2str(i), ' of ', num2str(length(npt)), ' events have been shuffled for epoch']);
        if args.percent_overlap == 0
        %    shuf_dat.rand_pdf(i).dist =...
        %        random_pdf_shuf(npt(i).tbins, npt(i).pbins, mega_pdf, n_shuf);
           
        %    shuf_dat.rand_tbins(i).dist =...
        %        random_tbins_shuf(npt(i).pdf, npt(i).tbins, npt(i).pbins, n_shuf);
           
        %    shuf_dat.rand_pos(i).dist = ...
        %        random_pos_shuf(npt(i).pdf, npt(i).tbins, npt(i).pbins, n_shuf);
        end
        
        shuf_dat.rand_tbins(i).dist = random_time_shift(clusters, rep_data.trig(i,:), tc,  n_shuf, args.percent_overlap);
        shuf_dat.rand_pos(i).dist = random_tc_shift(clusters, rep_data.trig(i,:), tc, n_shuf, args.percent_overlap);
        shuf_dat.rand_identity(i).dist = random_identity(clusters, rep_data.trig(i,:), tc, n_shuf, args.percent_overlap);
       % wb = my_waitbar(i/length(npt), wb);
       % drawnow
    end
     
end
%% The folloing shuffles are to be used with the reconstruction that has
%% overlapping time windows

function dist = random_time_shift(clusters, trig, tc, n_shuffle, per_over)
%     disp('Doing random TIME SLIDE shuffles');
    dist = nan(n_shuffle, 1);
    for  i=1:n_shuffle
        for j=1:length(clusters)
            fake_cells(j).time = shift_times(trig(1), trig(2), clusters(j).time);        
        end
        [pdf tbins] = reconstruct(trig(1), trig(2), tc, fake_cells, 'tau', .02, 'percent_overlap', per_over);
        pdf = pdf(:,:,1);
        pbins = 1:size(pdf,1);
        [sl inter sc] = est_line_detect(tbins(:,1), pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc; 
    end    
end

function times = shift_times(ts, te, times)
    times = times + random('uniform', 1, te-ts, 1);
    ind = times > te;
    times(ind) = times(ind) - (te-ts);
end

function dist = random_tc_shift(clusters, trig, tc, n_shuffle, per_over)
%     disp('Doing random TUNING CURVE circ-shift shuffles');
    dist = nan(n_shuffle, 1);
    for  i=1:n_shuffle
        for j=1:length(clusters)
            fake_tc = tc_shift(tc);
        end
        [pdf tbins] = reconstruct(trig(1), trig(2), fake_tc, clusters, 'tau', .02, 'percent_overlap', per_over);
        pdf = pdf(:,:,1);
        pbins = 1:size(pdf,1);
        [sl inter sc] = est_line_detect(tbins(:,1), pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc; 
    end    
end

function tc = tc_shift(tc)
    n_bins = size(tc,1);
  
    shift = ceil(random('uniform', 1, size(tc,1), size(tc,2), 1));
    for i=1:size(tc,2)
        tc(:,i) = circshift(tc(:,i), shift(i));
    end
end

function dist = random_identity(clusters, trig, tc, n_shuffle, per_over)
%     disp('Doing random CELL IDENTIFY shuffles');
    dist = nan(n_shuffle, 1);
    for  i=1:n_shuffle
        fake_tc = randomize_tc(tc);
        [pdf tbins] = reconstruct(trig(1), trig(2), fake_tc, clusters, 'tau', .02, 'percent_overlap', per_over);
        pdf = pdf(:,:,1);
        pbins = 1:size(pdf,1);
        [sl inter sc] = est_line_detect(tbins(:,1), pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc; 
    end    
end

function tc = randomize_tc(tc)  %swaps the cell identities
    n_tc = size(tc,2);
    new_ind = randsample(n_tc, n_tc, false);
    tc = tc(:,new_ind);
end


 

%% The following shuffles cannot be used for the reconstruction that is
%% done with overlapping windows.
%% Random PDF shuffle
function dist = random_pdf_shuf(tbins, pbins, mega_pdf, n_shuffle)
%     disp('Doing random PDF shuffles');
    dist = nan(n_shuffle,1);
    for i=1:n_shuffle
        ind = randsample(size(mega_pdf,2),length(tbins));
        pdf = mega_pdf(:,ind);
        %pdf_sm = smooth_pdf(pdf);
        [a b sc] = est_line_detect(tbins, pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc;
    end
end

%% Random tbins Shuffle
function dist = random_tbins_shuf(pdf,tbins, pbins, n_shuf)
%     disp('Doing random TIME-PDF shift  shuffles');
    dist = nan(n_shuf,1);
    for i=1:n_shuf
        % reorder time bins
        ind = randsample(size(pdf,2), size(pdf,2));
        pdf = pdf(:,ind);
        %pdf_sm = smooth_pdf(pdf);
        [a b sc] = est_line_detect(tbins, pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc;
    end
end

%% Random pos shift shuffle (can't be used for smooted case)
function dist = random_pos_shuf(pdf, tbins, pbins, n_shuf)
%     disp('Doing random POS-PDF shift shuffles');
    dist = nan(n_shuf,1);
    for i=1:n_shuf
        % reorder time bins
        for col_ind=1:size(pdf,2)
            pdf(:,col_ind) = circshift(pdf(:,col_ind), floor(rand(1)*size(pdf,1)));
        end
        %pdf_sm = smooth_pdf(pdf);
        [a b sc] = est_line_detect(tbins, pbins, pdf, 'kernelwidth', [3 1]);
        dist(i) = sc;
    end
end

function pdf = smooth_pdf(pdf)
    pdf = smoothn(pdf, 3, 'kernel', 'box', 'normalize', 0);
end

