function plot_exp_recon(recon, varargin)
args.pos = [];
args.rast = [];
args.mu = [];
args.eeg = [];
args.ripple_power = 1;
args.color = 'yr';
args.eeg_ch = 1;
args.external_axes = [];
args.external_axes_weight = 1.5;
args.pos_color = 'w';
if ~isempty(recon)
    args.structures = {recon.loc};
else
    args.structures = {};
end
args = parseArgsLite(varargin, args); %#ok
if ~iscell(args.structures)
    args.structures  = {args.structures};
end


if numel(recon)>1 && strcmp(args.structures{1},'global')
    for i=2:numel(recon)
        recon(1).pdf = recon(1).pdf + recon(i).pdf;
    end
    recon(1).pdf = normalize(recon(1).pdf);
    recon = recon(1);
end

if isempty(args.structures)
    args.structures = {'global'};
end

if numel(args.structures)==1 && numel(args.eeg_ch)>1
    args.structures = repmat(args.structures, size(args.eeg_ch));
elseif numel(args.eeg_ch)==1 && numel(args.structures)>1
    args.eeg_ch = repmat(args.eeg_ch, size(args.structures));
elseif numel(args.eeg_ch)==numel(args.structures)
else
    error('Invalid eeg channels specified, must provide 1 channel or 1 for each structure');
end
        

figure('Position', [100 350 1300 800], 'NumberTitle', 'off', 'Name', 'Exp Recon');
a = []; %axes

RECON = 0;
RAST = 0;
MU = 0;
EEG = 0;
EXT = 0;
xlims  = [];
setup_axes();   

if ~isempty(recon)
    plot_recon();
end
if ~isempty(args.rast)
    plot_rast();
end
if ~isempty(args.mu)
    plot_mu();
end
if ~isempty(args.eeg)
    plot_eeg();
end


linkaxes(a,'x');
% 
% set(a,'Box', 'on', 'XTick', []);
% ind = max([EXT EEG MU RAST RECON]);
% c = get(a(ind), 'children');
% disp(get(a(ind),'UserData'))
% x = get(c(1),'XData');
% 
% if iscell(x)
%     x = x{1};
% end
% xt = floor(x(1)):floor(x(end));
% set(a(ind), 'XTick', xt);

next_btn = uicontrol('Style', 'PushButton', 'String', '-->', 'units', 'normalized',...
    'position', [.9 .01 .05 .025], 'Callback', @next_fn);    %#ok
prev_btn = uicontrol('Style', 'PushButton', 'String', '<--', 'units', 'normalized',...
    'position', [.85  .01 .05 .025], 'Callback', @prev_fn);  %#ok

    function setup_axes()
        %Global axes positions
        min_x = .025;
        dx = .95;
        min_y = .05; 
        dy = .925;
        % Axes weights - determines how much of the figure is used up by
        % the axes
        re = 6;
        ra = 4;
        mu = 1.5;
        ee = 1.5;
        ext = args.external_axes_weight;
        tw = 0;
        
        %% set ax inds and weights
        if ~isempty(recon)
            RECON = 1;
            tw = tw + re;
        end
        if ~isempty(args.rast)
            RAST = max([RECON]) +1; %#ok
            tw = tw + ra;
        end
        if ~isempty(args.mu)
            MU = max([RECON RAST]) + 1;
            tw = tw + mu;
        end
        if ~isempty(args.eeg)
            EEG = max([RECON RAST MU])+1;
            tw = tw + ee;
        end
        if ~isempty(args.external_axes)
            EXT = max([RECON RAST MU EEG]) + 1;
            tw = tw + ext;
        end
        
        %% create the axes
        max_y = min_y;
        
        if EXT
            ax_pos = [min_x, max_y, dx, dy*ext/tw];
            a(EXT) =  axes('Position', ax_pos, 'XTick', [], 'YTick', [], 'Color', 'k');
            children = get(args.external_axes, 'Children');
            copyobj(children, a(EXT));
      
            max_y = ax_pos(2) + ax_pos(4);
        end
        
        if EEG
            ax_pos = [min_x, max_y, dx, dy*ee/tw];
            a(EEG) = axes('Position', ax_pos, 'XTick', [], 'YTick', [], 'Color', 'k');
            set(a,'UserData', 'Word');
            max_y = ax_pos(2) + ax_pos(4);
        end
        if MU
            ax_pos = [min_x, max_y, dx, dy*mu/tw];
            a(MU) = axes('Position', ax_pos, 'XTick', [], 'YTick', [], 'color', 'k');
            max_y = ax_pos(2) + ax_pos(4);
        end
        if RAST
            ax_pos = [min_x, max_y, dx, dy*ra/tw];
            a(RAST) = axes('Position', ax_pos, 'XTick', [], 'YTick', [], 'Color', 'b');
            max_y = ax_pos(2) + ax_pos(4);
        end
        if RECON
            ax_pos = [min_x, max_y, dx, dy*re/tw];
            a(RECON) = axes('Position', ax_pos, 'XTick', [], 'YTick', [], 'Color', 'y');
            max_y = ax_pos(2) + ax_pos(4);
        end       
        
    end
    function plot_recon()
        %[d1 d2 d3] = size(recon(1).pdf);
        pdf = [];%zeroes(d1*numel(recon(1)),d2,d3);
        tbins = recon(1).tbins;
        pbins = recon(1).pbins;
        
        pb = [];
        for i=1:numel(recon)  
            pb = [pb, pbins + max(pbins)*(i-1)]; 
            p = recon(i).pdf;
            switch mod(i,2);
                case 0 % Red, Green
                    t = p(:,:,2);
                    p(:,:,2) = p(:,:,3);
                    p(:,:,3) = t;
                case 1 %
                    p(:,:,2) = p(:,:,1);
                otherwise
                    warning('Only two color schemes implemented');         
            end
            if isempty(pdf)
                pdf = p;
            else
                pdf = [pdf; p]; 
            end
        end
        set(a(RECON), 'Xtick', []);
        
        % %% Red and Green
        %  t = recon.pdf(:,:,2);
        %  recon.pdf(:,:,2) = recon.pdf(:,:,3);
        %  recon.pdf(:,:,3) = t;
        % 
        % %% Blue and Yellow
        %  recon.pdf(:,:,2) = recon.pdf(:,:,1);  
        %  recon.pdf(:,:,3) = recon.pdf(:,:,3);
        % 
        % 
        %pdf = 1-pdf;
        imagesc(tbins,pb,pdf, 'Parent', a(RECON)); 
        set(a(RECON), 'YDir', 'normal');
        if ~isempty(args.pos)
            for i = 1:numel(recon)          
                line(args.pos.ts, args.pos.lp+max(args.pos.lp)*(i-1), 'LineStyle', 'none','Marker', '.', 'Color', args.pos_color, 'Parent', a(RECON), 'linewidth', 3, 'markersize', 1);
            end
        end
%         for i=1:numel(recon)
%             [.05 .05+i/(numel(recon))-.25, .05 .05]
%             uicontrol('Style', 'pushbutton', 'Position', [.05 .05+i/(numel(recon))-.25, .05 .05], 'String', recon(i).loc);
%         end

    end
    function plot_rast()
    end
    function plot_mu()
        for i=1:numel(args.structures)
            s = args.structures{i};
            col = args.color(mod(i,numel(args.color))+1);
            
            if strcmp('all', s)
                fn = fieldnames(args.mu);
                wave = zeros(size(args.mu.(fn{1})));
                for j = 1:numel(fn)
                    f = fn{j};
                    if strcmp(f, 'ts')
                        continue
                    end
                    wave = wave + args.mu.(f);
                end
            else
                wave = args.mu.(s);
                wave = wave/( max(wave) * numel(args.structures) );
                wave = wave+(i-1).*1/numel(args.structures);
            end
            patch_browser(wave, args.mu.ts, 'color', col, 'axes', a(MU));
        end
    end
    function plot_eeg()
       
        ts = args.eeg.ts;
        m = 0;
        for i=1:numel(args.eeg_ch)
            col = args.color(mod(i,numel(args.color))+1);
            
            if ~strcmp(args.structures(i), 'global')
                val_structures = find(strcmp(args.eeg.loc, args.structures(i)));
                ind = val_structures(args.eeg_ch(i));
            else
                ind = args.eeg_ch(i);
            end    
            wave = args.eeg.data(ind,:);
            wave = wave+m;
            m = mean(wave)+10*std(wave);
            line_browser(wave,ts,'color', col, 'axes', a(EEG));
        end
        
    end

%%%% Callbacks
    function next_fn(varargin)
        get_xlims();
        w = xlims(2) - xlims(1);
        w = w*.9;
        s = xlims(1) + w;
        e = xlims(2) + w;
%         dt = max(exp.(ep).epoch_times) - e;
%         if dt<0
%             e = e+dt;
%             s = s+dt;
%             disp('At end of Experiment, cant scroll anymore');
%         end
        set(a(1), 'XLim', [s e]);
    end
    function prev_fn(varargin)
        get_xlims();
        w = xlims(2) - xlims(1);
        w = w*.9;
        s = xlims(1) - w;
        e = xlims(2) - w;
        
%         dt = s - min(exp.(ep).epoch_times) ;
%         if dt<0
%             e = e-dt;
%             s = s-dt;
%             disp('At start of Experiment, cant scroll anymore');
%         end
        set(a(1), 'XLim', [s e]);
    end
    function get_xlims()
        xlims = get(a(1),'Xlim');
    end
pan('xon');
zoom('xon');
end