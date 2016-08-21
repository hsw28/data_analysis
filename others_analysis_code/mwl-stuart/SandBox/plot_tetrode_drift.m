function plot_tetrode_drift(amps, varargin)

args.time_win = [-Inf Inf];
args = parseArgsLite(varargin,args);
t1 = [args.time_win(1) mean(args.time_win)];
t2 = [mean(args.time_win) args.time_win(2)];

amps1 = select_amps_by_feature(amps, 'feature' ,'col', 'col_num', 5, 'range', t1);
amps2 = select_amps_by_feature(amps, 'feature' ,'col', 'col_num', 5, 'range', t2);

args = parseArgsLite(varargin, args);
amps = select_amps_by_feature(amps, 'feature', 'col', 'col_num', 5, 'range', args.time_win);

pf = figure('Position', [280 29 750 1000]);
a(1) = axes('Position', [.05 .05 .925 .45], 'color', 'k', 'Parent', pf);
a(2) = axes('Position', [.05 .525 .925 .45], 'color', 'k', 'Parent', pf);



%cf = figure('Position', [206 150 319 41], 'menubar', 'none');
% 
 prevBtn = uicontrol('Units', 'Normalized', 'Style', 'Pushbutton',...
     'Position', [.3 .015 .15 .025], 'callback', @prev, ...
     'String', '<--', 'Parent', pf);
 nextBtn = uicontrol('Units', 'Normalized', 'Style', 'Pushbutton',...
     'Position', [.46 .015 .15 .025], 'callback', @next, ...
     'String', '-->', 'Parent', pf);
 
 
 
l(1) = line(nan,nan, 'Parent', a(1), 'color', 'r', 'linestyle', '.', 'markersize', 20);
l(2) = line(nan,nan, 'Parent', a(1), 'color', 'w', 'linestyle', '.');

l(3) = line(nan,nan, 'Parent', a(2), 'color', 'r', 'linestyle', '.', 'markersize', 20);
l(4) = line(nan,nan, 'Parent', a(2), 'color', 'w', 'linestyle', '.');
%set(l, 'LineStyle', '.', 'MarkerSize', 1);
 
aInd = 1;
nAmp = numel(amps);
plot_amps();

    function next(varargin)
        if aInd<nAmp
                aInd = aInd+1;
        end
        plot_amps;
    end
    function prev(varargin)
        if aInd>1
                aInd = aInd-1;
        end        
        plot_amps;
    end

    function closeFn(varargin)
        close(pf);
        close(cf);
    end

    function plot_amps()
       set(l(1),'XData', amps1{aInd}(:,1), 'YData', amps1{aInd}(:,2));
       set(l(2),'XData', amps2{aInd}(:,1), 'YData', amps2{aInd}(:,2));
       
       set(l(3),'XData', amps1{aInd}(:,3), 'YData', amps1{aInd}(:,4));
       set(l(4),'XData', amps2{aInd}(:,3), 'YData', amps2{aInd}(:,4));
       
       set(a,'XLim', [0 800], 'YLim', [0 800]);
    end
end
