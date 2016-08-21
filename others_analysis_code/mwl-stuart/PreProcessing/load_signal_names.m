function sig_names = load_signal_names(session_dir)

sources = open(fullfile(session_dir, 'sources.mat'));
signals = open(fullfile(session_dir, 'signals.mat'));


sources = sources.sources;
signals = signals.signals;
sig_names = [];
for s = 1:length(signals)
    sig_names(s,:) = get_source_name(signals(s).source_id, sources);
end

    function s_name = get_source_name(source_id, sources)
        num = str2double(source_id);
        for i=1:length(sources)
            if sources(i).source_num == num
                s_name = sources(i).source_name;
                return;
            end
        end
        
        s_name = ['Source Not Defined: ', source_id];
    end
end
