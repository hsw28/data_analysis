function yhat = plane_wave_model(beta,x,varargin)

% PLANE_WAVE_MODEL Model plane wave
%  YHAT = PLANE_WAVE_MODEL(BETA,X) gives predicted values of Y in YHAT
%  as a function of vector of wave parameters BETA, and independent
%  variable matrix X.  
%
%  BETA must have 5 elements:
%   [temporal frequency, spatial wavelength, wave_angle, initial phase, amplitude]
%  
%  X must have 3 columns:
%   [time, x position, y position]
%
%
%  

p = inputParser();
p.addParamValue('yhat_form','value',@(x) any(strcmp(x,{'phase','value'})));
p.addParamValue('draw',false,@islogical);
p.addParamValue('fps',10);
p.parse(varargin{:});
opt = p.Results;

nparam = 5;
niv = 3;
n_obs = size(x,1);

% check and fix beta to be size [1, nparam]
if(not(all(size(beta) == [1, nparam])))
    if(not(all(size(beta) == [n_obs, nparam])))
        if(not(all(size(beta) == [nparam, 1])))
            error(['beta must be ', num2str(nparam), ' elements']);
        else
            beta = beta';
        end
    end
end

% check x size
if(not(size(x,2) == 3))
    error('x must have 3 columns: time, x position, y position');
end

if(size(beta,1) == 1)
    beta_big = repmat(beta,size(x,1),1);
else
    beta_big = beta;
end

time = x(:,1);
x_pos = x(:,2);
y_pos = x(:,3);
initial_time = min(x(:,1)) * ones(size(time));
freq = beta(:,1);
lambda = beta(:,2);
theta = beta_big(:,3);
initial_phase = beta(:,4);
amp = beta(:,5);

temporal_part = (2*pi*freq) .* (time); % should this be time - initial_time ?
proj = -1.*dot([x_pos,y_pos],ones(n_obs,2).*[cos(theta),sin(theta)],2);
spatial_part = (2.*pi./lambda) .* proj;

if(strcmp(opt.yhat_form,'value'))
    yhat = amp.*cos(temporal_part + spatial_part + initial_phase.*ones(n_obs,1));
elseif(strcmp(opt.yhat_form,'phase'))
    yhat = mod((temporal_part + spatial_part + initial_phase*ones(n_obs,1)),2*pi);
else
    error('Unrecognized y_hat_form.  value or phase, please.');
end

% sanitize
yhat(isnan(yhat)) = 0;
yhat(yhat == Inf) = 1000000;

if(opt.draw)
    u_times = unique(time);
    u_x = unique(x(:,2));
    u_y = unique(x(:,3));
    n_x = numel(u_x);
    n_y = numel(u_y);
    x_span = [min(x_pos), max(x_pos)];
    y_span = [min(y_pos), max(y_pos)];
    %h = plot3(1,1,1,'k.','MarkerSize',6);
    h = mesh([1 1; 2 2],[1 2; 1 2],[1 2; 3 4]);
    for m = 2:numel(u_times)
        ind = (time == u_times(m));
        this_x = reshape(x_pos(ind),n_x,n_y)
        this_y = reshape(y_pos(ind),n_x,n_y)
        this_z = reshape(yhat(ind),n_x,n_y)
        set(h,'XData',this_x);
        set(h,'YData',this_y);
        set(h,'ZData',this_z);
        %get(h)
        %set(h,'XData',x_pos(ind));
        %set(h,'YData',y_pos(ind));
        %set(h,'ZData',yhat(ind));
        %plot3(x_pos(ind),y_pos(ind),yhat(ind),'.');
        xlim(x_span);
        ylim(y_span);
        zlim([min(yhat)-0.1,max(yhat)+0.1]);
        title(num2str(u_times(m)));
        if(numel(u_times) > 1)
            if(isempty(opt.fps))
                pause(1/numel(u_times)); % this makes the whole sequence last 1 second
            else
                pause(1/opt.fps);
            end
        end
    end
end