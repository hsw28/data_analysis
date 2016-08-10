function f = scratch_acorr_movie( acorr_by_t, trodexy, varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('framerate',30);
p.addParamValue('labeled_lags',[1/80 1/35]);
p.addParamValue('phase_cdat',[]);
p.parse(varargin{:});
opt = p.Results;

x_coeff = 1.5;
y_coeff = 0.15;

n_ts = size(acorr_by_t.data,2);
n_lags = size(acorr_by_t.data,1);
n_chans = size(acorr_by_t.data,3);
ts = linspace(acorr_by_t.tstart, acorr_by_t.tend, n_ts);
dt = ts(2)-ts(1);

figure;

if(~isempty(opt.timewin));
    ok_bool = and(ts >= min(opt.timewin), ...
                  ts <= max(opt.timewin) );
    acorr_by_t.data = acorr_by_t.data(:, ok_bool, :);
    ts = ts(ok_bool);
    acorr_by_t.tstart = min(ts);
    acorr_by_t.tend = max(ts);
    n_ts = numel(ts);
end

phase_at_a_ts = interp1(conttimestamp(opt.phase_cdat),...
                                     opt.phase_cdat.data(:,1)',ts);
                                 
n_labels = 0;
if(~isempty(opt.labeled_lags))
    opt.labeled_lags = [-1.* opt.labeled_lags, opt.labeled_lags];
    n_labels = numel(opt.labeled_lags);
    acorr_value_at_labeled_lags = zeros(n_labels, n_ts,n_chans);
    for n = 1:n_labels
        for c = 1:n_chans
        acorr_value_at_labeled_lags(n,:,c) = ...
            interp1(acorr_by_t.lags_secs,...
            acorr_by_t.data(:,:,c), ...
            opt.labeled_lags(n));
        end
    end
end

        
        
for n = 1:n_ts
    hold off;
    for c = 1:n_chans
    

        plot(acorr_by_t.lags_secs * x_coeff + trodexy(c,1),...
           acorr_by_t.data(:,n,c) * y_coeff + trodexy(c,2));
      hold on;
       
          for m = 1:n_labels
        plot([opt.labeled_lags(m), opt.labeled_lags(m)].*x_coeff + trodexy(c,1), ...
               [0, acorr_value_at_labeled_lags(m,n,c)].*y_coeff + trodexy(c,2));
        
    end
      
    end
    
    if(~isempty(opt.phase_cdat))
        compass_x = 2.0;
        compass_y = -5.0;
        this_phase = phase_at_a_ts(n);
        plot( [-0.25 0.25]+compass_x, [compass_y,compass_y] ,'-');
        plot( [compass_x,compass_x], [-0.25, 0.25]+compass_y, '-');
        plot( [0, cos(this_phase)*0.25] + compass_x,...
              [0, sin(this_phase)*0.25] + compass_y );
    end
    

    
    xlim([1.5 5]); ylim([-5.5 -3]);
    title(num2str(ts(n)));
    pause(1/opt.framerate);
end
      
      
      
      
      