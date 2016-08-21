function plot_tetrode_spikes(amps, varargin)

args.time_win = [-Inf Inf];

args = parseArgsLite(varargin, args);
amps = select_amps_by_feature(amps, 'feature', 'col', 'col_num', 5, 'range', args.time_win);

pf = figure('Position', [119 234 910 680]);
a = axes('Position', [.05 .1 .925 .875], 'color', 'k', 'Parent', pf);



cf = figure('Position', [206 150 319 41], 'menubar', 'none');

prevBtn = uicontrol('Units', 'Normalized', 'Style', 'Pushbutton',...
    'Position', [.10 .2 .35 .5], 'callback', @prev, ...
    'String', '<--', 'Parent', cf);
nextBtn = uicontrol('Units', 'Normalized', 'Style', 'Pushbutton',...
    'Position', [.46 .2 .35 .5], 'callback', @next, ...
    'String', '-->', 'Parent', cf);

closeBtn = uicontrol('Units', 'normalized', 'style', 'pushbutton', ....
    'Position', [ .85 .2 .1 .5], 'callback', @closeFn, ...
    'String', 'X', 'Parent', cf);


l = line(nan,nan, 'Parent', a);
set(l, 'LineStyle', '.', 'Color', 'w', 'MarkerSize', 1);

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
       if size(amps{aInd},1)>0
            ind = randsample(size(amps{aInd},1), 10000);
       else
           ind = [];
       end
       set(l,'XData', amps{aInd}(ind,3), 'YData', amps{aInd}(ind,2));
       set(a,'XLim', [0 800], 'YLim', [0 800]);
    end
end
