function vel = calculate_velocity_gui(linear_pos)
% CALCULATE_VELOCITY_GUI(linear_position, threshold)
% 
% A Simple GUI used to determine an acceptable threshold for minimum
% velocity. 
%
% Position vs velocity is plotted and the velocity plot is updated as the
% user changes the threshold for velocity
fs = 1/30;

f = figure('Position', [520 600 820 430]); 
set(gcf, 'UserData', [.15 .250 0]);
%init_smooth = .250;
lin_pos = linear_pos;

slider = uicontrol('Style', 'Slider');

set(slider, 'Units', 'Normalized', 'Position', [0.92 0.11 0.025 0.815]);
set(slider, 'CallBack', {@slider_moved});
set(slider, 'Max', .5, 'Min', 0);
set(slider, 'SliderStep', [.005 .005], 'Value', .010);

smoother = uicontrol('Style', 'Slider');
set(smoother, 'Units','Normalized','Position', [0.95 0.11 0.025 0.815]);
set(smoother, 'Max', 1, 'Min', 0, 'Value', .550, 'SliderStep', [.001 .001]);
set(smoother, 'CallBack', {@set_smoothing});

done = uicontrol('Style', 'PushButton');
set(done, 'CallBack', @save_thold);
set(done, 'String', 'Done');
set(f, 'ToolBar', 'figure');

thold_lbl1 =uicontrol('Style', 'text','String', 'Vel Thold');
set(thold_lbl1,  'Position', [20 330, 70, 20]);

thold_lbl = uicontrol('Style', 'text', 'String', '10 cm/s');
set(thold_lbl, 'Position', [20 300, 70, 20]);

smth_lbl1 = uicontrol('Style', 'text', 'String', 'SmoothN');
set(smth_lbl1, 'Position', [20 250, 70, 20]);

smth_lbl = uicontrol('Style', 'text', 'String', '550 ms');
set(smth_lbl, 'Position', [20 220, 70, 20]);

u = uicontrol('Style', 'text', 'String', 'T');
set(u, 'Units', 'Normalized', 'Position', [.92 .93, .025 .025]);
u = uicontrol('Style', 'text', 'String', 'S');
set(u, 'Units', 'Normalized', 'Position', [.95 .93, .025 .025]);

plot_velocity();
%vel = smoothn(vel,10);  
%%%
%%% Figure.UserData(1) = Thold
%%% Figure.UserData(2) = Smoothing val
%%% Figure.USerData(3) = External Trigger signaling the end of GUI use
%%%

%%%%%% Slider Moved %%%%%%%%
    function slider_moved(varargin)
    %disp(['Slider Moved', num2str(get(varargin{1}, 'Value'))]);
    thold = get(varargin{1}, 'Value');
    plot_velocity();
    f = gcf;
    ud = get(gcf, 'UserData');
    ud(1) = thold;
    set(f, 'UserData', ud);
    
    set(thold_lbl, 'String', [num2str(floor(thold*1000)/10), ' cm/s']);   
    end    

%%%%%%% Plot %%%%%%%%%
    function plot_velocity()
     
        ud = get(f, 'UserData');
        thold = ud(1);
        smooth_std = ud(2);
        

        vel = gradient(lin_pos, fs); % calculate velocity;
               
        vel( abs(vel)>(4*std(vel) - mean(vel)) ) = 0; % remove outliers
                
        vel = smoothn(vel, smooth_std, fs);
        
        ind = abs(vel)<=thold; %threshold velocity
        vel(ind)=0;
        if max(vel)
            pos_range = max(lin_pos) - min(lin_pos);
            vel_range = max(vel) - min(vel);
            scale_factor = pos_range/vel_range;
            vel = vel-mean(vel);
            vel = vel*scale_factor;
        end

        xlim = get(gca, 'XLim');  % grab limits for zooming
        ylim = get(gca, 'YLim');

        vel = vel+mean(lin_pos);               
        plot(lin_pos, 'LineWidth',2); hold on; plot(vel, 'r', 'LineWidth', 2); hold off;
                
        if (xlim ~= [0 1] | ylim~=[ 0 1]) %#ok reset limits if they were'nt the original setup by figure()
            set(gca, 'XLim', xlim);
            set(gca, 'YLim', ylim);
        end       

    end

%%%%%% Set Smoothing  %%%%%%
    function set_smoothing(varargin)
        smooth_val = get(varargin{1}, 'Value');
        ud = get(gcf, 'UserData');
        ud(2) = smooth_val;
        set(gcf, 'UserData', ud);
        set(smth_lbl,'String', [num2str(floor(smooth_val*1000)), 'ms']);
        plot_velocity()
    end

%%%%%% Save Thold %%%%%%
    function save_thold(varargin)
        f = gcf;
        ud = get(f, 'UserData');
        ud(3) = 1;
        set(f, 'UserData', ud);
        disp('User Chosen Values:');
        disp(['     - Threshold:  ', num2str(ud(1))]);
        disp(['     - Smoothing:  ', num2str(ud(2))]);
    end

end