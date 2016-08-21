function gains = load_gains(file, varargin)

    args.type = 'tetrode';
    args = parseArgsLite(varargin, args);

    if strcmp(args.type, 'eeg');
        header_number = 3;
    else
        header_number = 2;
    end
    
    h = loadheader(file);
    
    field  = [repmat('channel ', 8,1) , num2str([0:7]'), repmat(' ampgain', 8,1)]; %#ok
    
    gains = nan(8,1);

    probe = str2double(h(1).Probe);

    for s=1:size(field,1)
        gains(s)= str2double(h(header_number).(field(s,:)));
    end
    
    if strcmp(args.type, 'tetrode')
        if probe
            gains = gains(1:4,:); 
        else
            gains = gains(5:8,:);
        end
    end
end
