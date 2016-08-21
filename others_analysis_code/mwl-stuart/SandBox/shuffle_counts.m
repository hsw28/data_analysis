function counts = shuffle_counts(rep, shuf, varargin)
% SHUFFLE_COUNTS performs the counts on the structures returned by
% replay_line_detection. 
%
% counts = shuffle_counts(replay_structure, shuffle_structure, 'epochs',
% {epochs});  performs the counts for the specified epochs
%
% counts = shuffle_counts( ... , 'p_value', p_val ) uses the specified
% p_val for the significance test.
%
% counts = shuffle_counts( ... , 'event_len', event_len) only counts events
% that are longer than the specified event length in seconds
%
%


args.p_value = .05;
args.epochs = '';
args.event_len = 0;
args = parseArgs(varargin, args);

counts = struct();

for ep = args.epochs
    e = ep{:};
    event_count = 0;
    sig_events = 0;
    event_ind = 0;
    pvals = nan(size(rep.(e).score,2),3);

    for i=1:size(rep.(e).score,2)
        p_vals = [nan nan nan ];
        if rep.(e).inputs(i).tbins(end) - rep.(e).inputs(i).tbins(1) >= args.event_len
            event_count = event_count+1;
            %[t1 p1] = test_for_sig(rep.(e).score(i), shuf.(e).rand_tbins(i).dist, args.p_value);
            [t2 p2] = test_for_sig(rep.(e).score(i), shuf.(e).rand_pos(i).dist, args.p_value);
            [t3 p3] = test_for_sig(rep.(e).score(i), shuf.(e).rand_identity(i).dist, args.p_value);
            t1 = t2;
            p1 = p2;
            pvals(i,:) = [p1 p2 p3];
            if t1 && t2 && t3
                sig_events = sig_events + 1;
                event_ind(sig_events) = i;
            end
        end
    end
    counts.(e).p_values = pvals;
    counts.(e).event_count = event_count;
    counts.(e).sig_events = sig_events;
    counts.(e).event_ind = event_ind;
end

end

function [sig p] = test_for_sig(score, dist, p)

    sig = numel(dist)*p > numel(find(dist>score));
    p = numel(find(dist>score)) / numel(dist);
end



        
            
        