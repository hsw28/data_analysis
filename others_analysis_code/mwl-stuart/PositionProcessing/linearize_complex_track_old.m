function [lin_pos nodes] = linearize_complex_track(xpos, ypos)
% LINEARIZE_CUSTOM_TRACK(xpos,ypos)
%
% A simple gui to subdivide a complex multi-trajectory track into a linear
% environment.
% linear_position is returned which ranges from 0 to x meters with x being
% the user specified length
%
% Order of Operations
%   1- Display all available points
%   2- Cut out desired trajectory
%   3- Linearize sub trajectory
%   4- Append linearized trajectory to current trajectory
%   5- Done?
%       no - Go to step 1
%       yes- End

    rx = xpos; 
    ry = ypos;
    r_ind = 1:length(xpos);
    lin_pos = nan(size(r_ind));
    list = {'Linear', 'Circular', 'Spline', }; 
    
    more = 'Yes';
    nodes = [];
    nnodes = 0;
    while strcmp(more, 'Yes');
        [sx, sy, s_ind, rx, ry, r_ind] = select_trajectory_points(rx, ry, r_ind);
        lin_pos_sel = linearize_custom_track(sx, sy);
        
        disp('s_ind,    lin_pos,  sx,  sy');
        disp([size(s_ind), size(lin_pos_sel), size(sx), size(sy)]);
        
        mp = max(lin_pos);
        if isnan(mp)
            lin_pos(s_ind) = lin_pos_sel;
        else
            lin_pos_sel = lin_pos_sel + mp;
            lin_pos(s_ind) = lin_pos_sel;
            nnodes=nnodes+1;
            nodes(nnodes) = mp;
        end
        
        plot(1:length(lin_pos), lin_pos, '.'); hold on; plot(s_ind, lin_pos_sel, 'rx');
        more = questdlg('Select another subregion of track?');
        
        close(gcf);
    end
end

function [sel_x, sel_y, s_ind, rem_x, rem_y, r_ind] = select_trajectory_points(xpos, ypos, pos_ind)
    f_sel = figure();
    a = axes('Units', 'Normalized', 'Position', [0.01, .075, .98, .915],...
        'XTick', [], 'YTick', [], 'Box', 'on');
    plot(xpos, ypos, '.')
    [x1, y1, x2, y2] = draw_dynamic_rectangle(a);
    x = sort([x1, x2]);
    y = sort([y1, y2]);
    close(f_sel);
    
    ind_x = x(1)<=xpos & x(2)>=xpos;
    ind_y = y(1)<=ypos & y(2)>=ypos;
    s_ind = ind_x & ind_y;
    r_ind = ~s_ind;    
    
    sel_x = xpos(s_ind);
    sel_y = ypos(s_ind);
    
    rem_x = xpos(r_ind);
    rem_y = ypos(r_ind);
    s_ind = pos_ind(s_ind);
    r_ind = pos_ind(r_ind);
end






