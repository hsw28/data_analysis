function [timestamp,new_data,cdat] = gh_debuffer(filename,varargin)
% [ts,data,cdat] = GH_DEBUFFER(filename, ['timewin', [0 Inf],
%                                         'chans', [],
%                                         'index_before_m_less_than_t',[1, 2000]
%                                         'system', ['ad' or 'arte],
%                                         'gains', [list] <- needed in arte case]



p = inputParser();
p.addParamValue('timewin',[0 Inf]);
p.addParamValue('chans',[]);
% use this option to filter out early buffers with pathologically large timestamps
p.addParamValue('index_before_m_less_than_t', [1 2000]);
p.addParamValue('system', []);
p.addParamValue('gains',[]);
p.addParamValue('always_drop_first_buffer',true);
p.addParamValue('quick_resample',[]);
p.addParamValue('arte_correction_factor',[]);
p.parse(varargin{:});
opt = p.Results;

if( any(strcmp('arte', opt.system)) && isempty(opt.arte_correction_factor) )
    error('gh_debuffer:uncorrected_arte','If you want to import arte files, you must also pass arte_correction_factor.');
end

eeg_o = mwlopen(filename);

% Select channels
if(isempty(opt.chans))
    chans = 1:(eeg_o.nchannels);
else
    chans = opt.chans;
end
n_file_chans = eeg_o.nchannels;
n_chans = numel(chans);

% Get channel gains, depends on whether data come from ad or arte
% (probably an issue with .eeg file's header in arte case)
if(isempty(opt.system))
    error('gh_debuffer:not_specified_system',...
        'Please include ''system'', ''ad''  or ''system'', ''arte'' in arguments.');
elseif(strcmp(opt.system,'arte'))
    if(isempty(opt.gains))
        error('gh_debuffer:arte_system_without_gains',...
            'Bug workaround: using arte system, pass ''gains'', [chan1_gain, ... , chann_gain]');
    else
        if(numel(opt.gains) == n_chans)
            lfp_gains = opt.gains;
        elseif(numel(opt.gains) == n_file_chans)
            lfp_gains = opt.gains;
            lfp_gains = lfp_gains(chans);
        elseif(numel(opt.gains) == 1)
            lfp_gains = opt.gains .* ones(1,n_chans);
        else
            error('gh_debuffer:wrong_sizeof_gains','Number of input gains must be one or match number of file input chans or number of requested chans');
        end
    end
elseif(strcmp(opt.system,'ad'))
    lfp_gains = getGains(eeg_o);
    lfp_gains = lfp_gains(chans);
end


ts = eeg_o.timestamp; % 'ts' will mean the buffer timestamps
                      % 'timestamp' refers to interpolated
                      % timestamps
ts = double(ts);

ts = ts ./ 10000; % ts units were 0.0001s per 1 unitdata = double(tmp_dat.data);

if(strcmp(opt.system,'arte'))
    warning('gh_debuffer:arte_correcting',...
        ['Correcting arte comp by adding time offset: ',num2str(opt.arte_correction_factor)]);
    ts = ts + opt.arte_correction_factor;
end

data = eeg_o.data;  

if(opt.always_drop_first_buffer)
    ts = ts(2:end);
    data = data(:,:,(2:end));
end
                                  
                                    

if( opt.timewin(1) < min(ts) || opt.timewin(2) > max(ts) )
    error('gh_debuffer:bad_timewin', ['Timewin [', num2str(opt.timewin), '] isn''t within recording time range.']);
end


% Interval between buffers.  Why not ts(2) - ts(1)?  Because of arte's int underflow
buf_dt = ts(100) - ts(99);
% Expand the user's timewindow by one buffer on each side.  We want to clip
% it down later with the interpolated timestamps (eg - user's timewindow might
% not fall exactly on a buffer boundary)
buf_timewin = opt.timewin + [-buf_dt, buf_dt];

% If growing out took us past the limits of the ts, bring them back
buf_timewin = [max( min(ts), buf_timewin(1)), min( max(ts), buf_timewin(end)) ];

% For each buffer ind, define the maximum timestamp that that buffer 
% (for dropping buffers that suffered from arte int-underflow problem))
max_ok_ts = Inf .* ones(size(ts));
% Most buffers can have any timestamp they like (max is Inf)
if(~isempty(opt.index_before_m_less_than_t))
    % buffers before the nth must have a timestamp less than t_n
    max_ok_ts(1:(opt.index_before_m_less_than_t(1))) = opt.index_before_m_less_than_t(2);
end
ts_ok = (ts >= buf_timewin(1) & ts <= buf_timewin(end) & ...
    (ts < max_ok_ts));


data = data(chans, :, ts_ok);
ts = ts(ts_ok);

% this should be called: n_samp_per_chan_per_buffer
n_samp_per_buf = size(data,2);
n_buf = size(data,3);
n_samp_per_chan = n_buf * n_samp_per_buf;

% Put chans in rows, times in columns concatenating buffers
data = reshape(data,n_chans,[],1);

% is this necessary?  Isn't it already that shape?
ts = reshape(ts,1,[]);



% Old way of interpolating timestamps from buffer ts.  Needs work,
% It's a pain to understand.  TODO: fix
ts_big = repmat(ts,n_samp_per_buf,1); % cols are within buf, new col, new buf

diffs = diff(ts);
diffs = [diffs,diffs(end)];
diffs2 = diff(diffs);
if(max(diffs2) > mean(diffs) * 0.05)
    max(diffs2);
    mean(diffs);
    % Rethink this test..
    %error('Max diffs2 > 0.05*mean(diffs)');
end
the_diff = mean(diffs); % we'll assume drop each ts is separated by about the same amount

add_vec = linspace(0,the_diff,(n_samp_per_buf+1))'; % we add a samp b/c linspace will take us all the way to the next ts, and we want 1 less than that
add_vec = add_vec(1:end-1); % here drop the last one
add_array = repmat(add_vec,1,n_buf); % copy the add vec down

ts_big = ts_big + add_array; % now all the timestapms are arranged in top-to-bottom, left-to-right.
new_timestamp = reshape(ts_big,1,[]); % turn it into a 1 by n vector



if(~isempty(p.Results.timewin))
    ok_ind = and(new_timestamp >= p.Results.timewin(1), new_timestamp <= p.Results.timewin(2));
else
    ok_ind = true(size(new_timestamp)); % array of trues same size as timestamp
end

timestamp = new_timestamp(ok_ind);
new_data = data(:,ok_ind);

clear add_array;
clear data;
clear new_timestamp;
clear ts_big;

%timestamp = timestamp';
new_data = new_data';  %nicer format for imcont
new_data = double(new_data);

% it's in ADCunits; convert to mV;      
% creates a vector of conv factors according to gains

adunits_to_mv_f = ...
	1/4095 .* ... % ADCrange/ADCunits (-2048 -> +2047)
	20 .* ... % ADCvolts/ADCrange (-10 -> +10)
	1./lfp_gains .*... % volts/ADCvolts (vector)
	1000; % mv/volt
      
% when gain is 0, conversion factor should be 0, not inf
adunits_to_mv_f(isinf(adunits_to_mv_f)) = 0;
      
for k = 1:length(chans),
	new_data(:,k) = new_data(:,k) .* adunits_to_mv_f(k);
end

%if(~strcmp(opt.system,'ad'))
%cdat = 1;
%else
cdat = imcont('timestamp',timestamp,'data',new_data,'dataunits','mv');
cdat.data = double(cdat.data);
%end

if ~isempty(opt.quick_resample)
    cdat = contresamp(cdat, 'resample', opt.quick_resample / cdat.samplerate );
end