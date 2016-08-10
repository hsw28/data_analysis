function xcorr_matrix = reconstruction_simple_xcorr_by_time(...
    r_pos_array, varargin)

p = inputParser();
p.addParamValue('max_lag_secs',0.5);
p.addParamValue('pos_info',[]);
p.addParamValue('min_running_speed',[]);
p.addParamValue('running_direction',[]);
p.parse(varargin{:});
opt = p.Results;

n_pdf = numel(r_pos_array);
n_ts = size(r_pos_array(1).pdf_by_t,2);
n_pos = size(r_pos_array(1).pdf_by_t,1);
ts = linspace(r_pos_array(1).tstart, r_pos_array(2).tend,n_ts);
dt = ts(2)-ts(1);

if(~isempty(opt.min_running_speed))
    % flip velocity and threshold if user wants inbound
    if(strcmp(opt.running_direction, 'inbound'))
        opt.min_running_speed = abs(opt.min_running_speed);
        opt.pos_info.lin_vel = -1.*opt.pos_info.lin_vel;
    end
    speed_at_ts = interp1( opt.pos_info.lin_vel_timestamp,...
                                              opt.pos_info.lin_vel', ts);
                                      
    valid_bool = speed_at_ts >= opt.min_running_speed;
    for n = 1:n_pdf
        r_pos_array(n).pdf_by_t(:, ~valid_bool) = 1/n_pos;
    end
end

max_lag_samps = floor(opt.max_lag_secs / dt);

lags = (-1*max_lag_samps):(max_lag_samps);
n_lags = numel(lags);
lags_secs = lags .* dt;

xcorr_matrix.lags = lags_secs;
xcorr_matrix.data = zeros(n_pdf, n_pdf, n_lags);

for m = 1:n_pdf
    m
    m_data = r_pos_array(m).pdf_by_t;
    for n = 1:n_pdf
        n
        n_data = r_pos_array(n).pdf_by_t;
        for c = 1:n_lags
            lags(c)
            if(lags(c) < 0)
                shift_m = lfun_shift_right(m_data, abs(lags(c)));
            elseif(lags(c) > 0)
                shift_m = lfun_shift_left(m_data, lags(c));
            elseif(lags(c) == 0)
                shift_m = m_data;
            end
        
            xcorr_matrix.data(m,n,c) =...
                corr(reshape(shift_m,[],1),...
                         reshape(n_data,[],1)); 
            
        end
    end
end

function shift_data = lfun_shift_right(data,samps)
old_front = data(:, 1:(end-samps));
old_back = data(:, (end-samps+1):end);
shift_data = [old_back, old_front];


function shift_data = lfun_shift_left(data,samps)
old_front = data(:, 1:samps);
old_back = data(:, (samps+1):end);
shift_data = [old_back, old_front];