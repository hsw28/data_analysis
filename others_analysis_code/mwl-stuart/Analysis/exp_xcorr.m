function [data exp] = exp_xcorr(exp, varargin)
% compute the cross-correlation of clusters across an entire experiment 
%
% possible input options are:
%   - use_mu_burst: [-1,0,1] default is 0, -1 is anti-multi-unit-burst


args = struct('use_mu_burst', 0, 'lags', [-.15:0.05:.15]);

if nargin>1
    args = parseArgsLite(varargin, args);
end

epochs = exp.epochs;


for i = epochs
    ep = i{1};
    
    in = struct('event_times', []);
    in = repmat(in, 1, length(exp.(ep).clusters));
    
    switch(args.use_mu_burst)
        case(-1) % use anti-bursts
            disp('Not yet supported');
        case(0) % use all the data
            for i=1:length(exp.(ep).clusters)
                in(i).event_times = exp.(ep).clusters(i).time;
            end
            
        case(1) % use bursts
            if ~isfield(exp.(ep), 'mub_times')
                disp('MUB not found, computing them...');
                exp.(ep).mub_times = find_mu_burst(exp.(ep).multiunit.times, exp.(ep).position);
                disp(' ...done! MU Bursts computed!');
            end
      
            for j=1:length(exp.(ep).clusters)
                in(j).event_times = exp.(ep).clusters(j).load_window({'time_window', exp.(ep).mub_times});
                
            end              
    end
    for i=1:length(exp.(ep).clusters)

        f1 = exp.(ep).clusters(i).field1;
        f2 = exp.(ep).clusters(i).field2;
        exp.(ep).clusters(i).com1 = sum(times(f1, 1:length(f1)))/sum(f1);
        exp.(ep).clusters(i).com2 = sum(times(f2, 1:length(f2)))/sum(f2);
    end
                
   [data.(ep).c data.(ep).e data.(ep).t] = struct_xcorr(in,  args.lags);
    
   ncorr=0;
   n_corr_total = (length(exp.(ep).clusters)-1)*(length(exp.(ep).clusters)/2);
   exp.(ep).f_corr1 = nan(n_corr_total,1);
   exp.(ep).f_corr2 = nan(n_corr_total,1);
   for k=1:length(exp.(ep).clusters)
        for j=k+1:length(exp.(ep).clusters)
            c1 = exp.(ep).clusters(k);
            c2 = exp.(ep).clusters(j);
            ncorr = ncorr+1;
            data.(ep).fcorr1(ncorr,:) = xcorr(c1.field1, c2.field1);
            data.(ep).fcorr2(ncorr,:) = xcorr(c1.field2, c2.field2);
            
            data.(ep).fd1(ncorr) = find(data.(ep).fcorr1(ncorr,:)==max(data.(ep).fcorr1(ncorr,:)));
            data.(ep).fd2(ncorr) = find(data.(ep).fcorr2(ncorr,:)==max(data.(ep).fcorr2(ncorr,:)));
            
            data.(ep).fd1(ncorr) = data.(ep).fd1(ncorr) - length(c1.field1);
            data.(ep).fd2(ncorr) = data.(ep).fd2(ncorr) - length(c1.field1);
            
            data.(ep).com_d1(ncorr) = c1.com1 - c2.com1;
            data.(ep).com_d2(ncorr) = c1.com2 - c2.com2;
            
        end
    end
end

end
