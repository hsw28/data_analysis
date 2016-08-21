function f = my_waitbar(val, varargin)

if nargin<1
    val = 0;
end

if isempty(varargin) || isempty(varargin{1})
    f = figure('Position', [400 400 350 30],'NumberTitle', 'off',...
        'MenuBar', 'none', 'Toolbar', 'none', 'Name', ['Waiting since: ', datestr(clock,13)],'UserData',-1);
    set(f,'UserData', -1);
    
    a = axes('Units', 'normalized', 'Position', [0.025 0.2 .95 .6],...
        'XTick', [], 'Ytick', [], 'Box', 'On', 'UserData', 'axes');
    set(a,  'XLim', [0 1], 'YLim', [0 1]);
else
    f = varargin{1};
    a = findobj(get(f,'Children'),'UserData', 'axes');
    if isempty(a)
        a = axes('Parent', f);  
    end
end


if val==1
    close(f)
    return;
elseif val>1
    error(['value cannot be greater then 1, value was: ,' val]);
end

args.color = 'r';

if nargin>1
    args = parseArgsLite(varargin(2:end),args);
end


%Check to see if val is up by more then 1%
if val == 0 || val-get(f,'UserData') >=.01 %only update when difference is 1% or greater


    %% Draw the waitbar
    p = findobj(get(a, 'Children'), 'UserData', 'patch');
    if isempty(p)
        p = patch([0 0 ], [0 1], args.color, 'Parent', a, 'UserData', 'patch');
    end

    set(p, 'XData', [0 0 val val], 'YData', [0 1 1 0]);       

    per = floor(val*1000)/10;
    %% Draw the % done string
    t = findobj(get(a, 'Children'), 'UserData', 'text');
    if isempty(t)
        t = text(.45, .25, [num2str(per) '%'], 'UserData', 'text', ...
                'Color', 'K', 'FontSize', 26, 'Parent', a);
    end
    set(t, 'String', [num2str(floor(per)) '%']);

    set(f, 'UserData', val);
else
    
end


drawnow; % allows the wait bar to be drawn if intense computation is going on
end
