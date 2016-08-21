function [f pp_data] = do_phase_precession(exp, varargin)
args.data = [];
args.epoch = [];
args.eeg_ch = 1;
cl_index = -1;
pos_bins = [];

args = parseArgs(varargin, args);
if isempty(args.epoch)
    error('No Epoch Specified');
end

f = figure('NumberTitle', 'off', 'Name', 'Phase Precession Browser',...
    'Position', [500 500 775 600], 'Toolbar', 'none');

TP = 1;
TC = 2;
a(TP) = axes('Parent', f, 'Units', 'Normalized', 'Position', [.05 .3 .75 .65], 'box', 'on', 'XTick', []);
a(TC) = axes('Parent', f, 'Units', 'Normalized', 'Position', [.05 .055 .75 .2], 'box', 'on');
list_box = uicontrol('Style', 'ListBox', 'Units', 'Normalized', 'Position', [.825 .30 .15 .65], ...
    'CallBack', @do_plot);

set(list_box, 'String', 1:numel(exp.(args.epoch).clusters));

if isempty(args.data)
    disp('No phase precession data provided, calculating it')
    pp_data = calculate_phase_precession(exp, 'eeg_ch', args.eeg_ch);
else
    pp_data = args.data;
end



pos_vector = [min(exp.(args.epoch).position.lin_pos) max(exp.(args.epoch).position.lin_pos) ];
pos = [];


    function do_plot(varargin)
        disp('do plot');
        cl_index = get(list_box, 'Value');
        plot_tc();
        plot_phase();       
    end

    function  plot_tc(varargin)
        disp('testing');

        cell = exp.(args.epoch).clusters(cl_index);
        if isempty(pos)
            pos_bins = pos_vector(1):cell.tc_bw:pos_vector(2);
        end;
        a1 = area(pos_bins, cell.tc1, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 4, 'Parent', a(TC));
        hold(a(TC), 'on');
        a2 = area(pos_bins, cell.tc2, 'FaceColor', 'none', 'EdgeColor', 'b', 'LineWidth', 4, 'Parent', a(TC));
        hold(a(TC), 'off');
        
        xlabel(a(TC), 'Position');
        ylabel(a(TC), 'Firing Rate');
    end
    

    function plot_phase(varargin)
        disp('plot phase');
        
        cell = pp_data.(args.epoch).cl(cl_index);
        phase_bins = -pi:pi/36:pi;
        img = scatter_image(cell.pos, cell.t_phase, 0:.05:max(pos_bins), phase_bins);
        img = smoothn(img, 2);
        imagesc(pos_bins, phase_bins, img, 'Parent', a(TP));
        set(a(TP), 'YDir', 'normal');
        hold(a(TP), 'on');
        plot(cell.pos, cell.t_phase, 'w.', 'Parent', a(TP));
        set(a(TP), 'xlim', get(a(TC), 'xlim'));
        hold(a(TP), 'off');
    end
         
        


end




%{

for e = exp.epochs
    ep = e{:};
   
    for i=1:length(d.(ep).cl)

        c = d.(ep).cl(i);
        x_b = 0:.05:max(c.pos);
        y_b = -pi:pi/36:pi;
        img = scatter_image(c.pos, c.t_phase, 0:.1:max(c.pos), -pi:pi/36:pi);
        
        h = ceil(size(img,1)/2);
        img = [img(h:end,:); img; img(1:h,:)];
        img = smoothn(img, 5);
        pause;
        imagesc(x_b, -2*pi:pi/12:2*pi, img);
        set(gca, 'YDir', 'Normal');
        ylabel('Phase');
        xlabel('Position');
        title([ep, ' ', num2str(i)]);

    end
end

end

%}