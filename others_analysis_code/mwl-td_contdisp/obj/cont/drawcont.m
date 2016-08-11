function hs = drawcont(varargin)
% DRAWCONT plot a cont object, using prefs from contopt, contdrawopt

  hs = [];
  
  a = struct('cont', [],...
             'opt', [],...
             'plottypeno', [],...
             'whitebg', [],...
             'ax', [],...
             'dpi', [],...
             'xlim', []);
  
  
  a = parseArgs(varargin,a);
  
  %%% setup
  
  if isempty(a.opt),
    a.opt = mkcontdrawopt();
  end
  
  if isempty(a.ax),
    a.ax = gca;
  end
  
  % get axis size
  oldunits = get(a.ax,'units');
  set(a.ax,'units','pixels');
  axpospix = get(a.ax,'position');
  set(a.ax,'units', oldunits);
  
  % guess at what plot to make if none provided
  if isempty(a.opt.plottype)
    if ndims(a.cont.contdata.data) > 2, 
      error('only 1-D and 2-D data supported');
    else
      a.opt.plottype = 'line';
    end
  end
  
  % set 'linear' (non-'log') scaling
  set(a.ax, 'yscale', 'linear');
  
  % choose a default colororder; rotate it depending on plot number
  if isempty(a.opt.color),
    a.opt.color = hsv(8);
    if ~isempty(a.plottypeno),
      a.opt.color= circshift(a.opt.color,-a.plottypeno+1);
    end
    if a.whitebg,
      a.opt.color= rgb2hsv(a.opt.color);
      a.opt.color(:,3) = 0.7;
      a.opt.color= hsv2rgb(a.opt.color);
    end
  end
  
  %%% subsample to speed plotting
  
  if ~isempty(a.dpi)
    set(a.ax, 'units', 'inches');
    axpos_in = get(a.ax, 'position');
    axwidpix = axpos_in(3) * a.dpi;
    set(a.ax, 'units', 'pixels'); % reset
  else
    axwidpix = axpospix(3);
  end
  
  switch a.opt.plottype,
   case {'line' 'area'},
    sampsperpix = 20;
   case 'image',
    sampsperpix = 1;
   otherwise,
    error('unrecognized ''plottype''');
  end
  
  nsamps = a.cont.timewini(2) - a.cont.timewini(1);
  
  if nsamps < sampsperpix*axwidpix || ~a.opt.subsample
    % plot all, no subsample
    step = 1;
  else
    % step
    step = floor(nsamps/axwidpix/sampsperpix);
  end
  
  
  % get the time window specified by the timewini indexes
  timewin = a.cont.contdata.tstart + (a.cont.timewini/a.cont.contdata.samplerate);

  % get the data limits to use (ylim in line plot, zlim in image plot)
  if ~isempty(a.opt.datalim),
    datalim = a.opt.datalim;
  else
    ranges = a.cont.contdata.datarange;
    datalim = [min(ranges(:,1)) max(ranges(:,2))];
  end
  
  %%% plot the data
  switch a.opt.plottype,
    
   %% line plot
   case {'line' 'area'}
    
    set(a.ax,'ColorOrder', a.opt.color);
    set(a.ax,'LineStyleOrder', a.opt.linestyle);
    set(a.ax,'NextPlot', 'add'); % preserves colororder on 'plot'
    % plot:
    % data timestamps = cont.tstart + ((indexes-1) * 1/samplerate)
    % vs.
    % data = data(indexes)
    dtimes = a.cont.contdata.tstart + ... 
             (((a.cont.timewini(1):step:a.cont.timewini(2))-1)/ a.cont.contdata.samplerate);
    
    data = a.cont.contdata.data(a.cont.timewini(1):step:a.cont.timewini(2),:);

    if strcmp(a.opt.plottype, 'line')
      h = plot(a.ax, dtimes, data);
    else
      h = area(a.ax, dtimes, data);

      % area doesn't obey the usual plot color ordering
      for k = 1:length(h)
        ncol = length(a.opt.color);
        kmod = mod(k,ncol);
        kmod(kmod==0)=ncol;
        set(h(k), 'facecolor', a.opt.color(kmod,:));
        set(h(k), 'edgecolor', a.opt.color(kmod,:));
      end
        
    end
    
% $$$     h = plot(a.ax,...
% $$$              a.cont.contdata.tstart + ... 
% $$$              (((a.cont.timewini(1):step:a.cont.timewini(2))-1)/a.cont.contdata.samplerate),...
% $$$              a.cont.contdata.data(a.cont.timewini(1):step:a.cont.timewini(2),:));
    
    hs = [hs; h];
    
    % contlevels - dashed lines at particular y-values
    % (plot even if no data)
    if ~isempty(a.opt.levels),
      h = plot(a.ax,...
               repmat(timewin(:),1,length(a.opt.levels)),...
               repmat(a.opt.levels,2,1), ...
               '--',...
               'color', a.opt.color(1,:) .* a.opt.levelscolf);

      hs = [hs; h];
    end

    % set requested ylims
    if diff(datalim) > 0,
      ylim(a.ax, datalim);
    else
      %warning('requested datalims are non-increasing; ignoring')
    end
    
    %% image plot
   case 'image',
    
    % get image data to plot
    imdata = a.cont.contdata.data(a.cont.timewini(1):step:a.cont.timewini(2),:)';
    
    % y-axis labels
    if ~isempty(a.cont.contdata.chanvals),
      chanvals = a.cont.contdata.chanvals;
    else % just enumerate rows
      chanvals = 1:size(imdata,1);
    end
    
    imh = draw2d('data', imdata,...
               'xhistendedges', timewin,...
               'yhistctrs', chanvals,...
               'ax', a.ax,...
               'cmap', a.opt.cmap,...
               'cmapwin', a.opt.cmapwin,...
               'datalim', datalim,...
               'ydir', 'reverse');
    hs = [hs; imh];

    lims = objbounds(imh);
    ylim(a.ax, lims(3:4));
    
  end

  if a.opt.drawlegend,
    h = contdrawlegend('chanlabels', a.cont.contdata.chanlabels, ...
                       'dispname', a.opt.dispname,...
                       'plottype', a.opt.plottype,...
                       'colororder', a.opt.color,...
                       'whitebg', a.whitebg,...
                       'ax', a.ax);
    
    %'cmaptop', [1 1 1],...
    
    hs = [hs; h];
  end
  
  %%% set xlim (usu according to requested timewin_plot)
  if ~isempty(a.xlim),
    xlim(a.ax, a.xlim),
  end
  
  % remove numbers from x/y axes if requested. Leave ticks
  if ~a.opt.drawxaxis,
    set(a.ax,'xticklabel', []);
  end
  
  if ~a.opt.drawyaxis,
    set(a.ax,'yticklabel', []);
  end
  