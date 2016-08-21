function gain = load_eeg_gains(file, channel, varargin)
% load_eeg_gains(file, channel) loads the gain for the specified channel
% load_eeg_gains(... , header_number) overrides the default header number
% of 3 and allows the user to specify a header number
    header_number = 3;
    if ~isempty(varargin)
        header_number = varargin{1};
    end
    
    h = loadheader(file);

    field  = ['channel ', num2str(channel-1), ' ampgain'];
    %n_headers = str2double(h(0).subheaders);
    gain = str2double(h(header_number).(field));
end
