% get some cont data
load ('~/data/paul/05/cont/cdat_p05run_e1_all');
load ('~/data/paul/05/cont/cdat_p05run_e2_all');
load ('~/data/paul/05/cont/cdat_p05run_e3_all');

cdat_e1 = cdat_p05run_e1_all;
cdat_e1 = contchans(cdat_e1, 'chans', 1:6);
ttlist = [7 8 9 10 11 12];

cdat_e2 = cdat_p05run_e2_all;
cdat_e2 = contchans(cdat_e2, 'chans', 3:4);
ttlist = [ttlist 6 1];

cdat_e3 = cdat_p05run_e3_all;
cdat_e3 = contchans(cdat_e3, 'chans', [1 2 4]);
ttlist = [ttlist 16 17 13];

%% paul05 tetrode locations in arbitrary units (actually squares on my
%lab notebook, p.37. Only useful for relative positioning)

xyloc{1} = [10.5 -11.5];
xyloc{2} = [14 -12];
xyloc{3} = [16 -10.5];
xyloc{4} = [11.5 -5];
xyloc{5} = [11.5 -5];
xyloc{6} = [16 -4.5];
xyloc{7} = [13 -7];
xyloc{8} = [14 -3];
xyloc{9} = [12 -2];
xyloc{10} = [9 -6];
xyloc{11} = [9 -3];
xyloc{12} = [6.5 -4.5];
xyloc{13} = [5.5 -6];
xyloc{14} = [5.5 -9];
xyloc{15} = [7 -10.5];
xyloc{16} = [8.5 -12.5];
xyloc{17} = [9 -10];
xyloc{18} = [12.5 -9.5];

trodexy = vertcat(xyloc{ttlist});


%%% select times

% nice: 3 spw in a row
%timewin = [5067.6 5068];

% fwd replay, even amplitudes
%timewin = [7186 7186.5];

% ripps diff on tt6/tt1 email fk example
%timewin=[6270.4 6270.7]

timewin=[7101.9 7102.7];

cdat_e1_win = contwin(cdat_e1, timewin + [-1 1]);
cdat_e2_win = contwin(cdat_e2, timewin + [-1 1]);
cdat_e3_win = contwin(cdat_e3, timewin + [-1 1]);

cdat_e123_win = contcombine(cdat_e1_win, {cdat_e2_win cdat_e3_win}, ...
                            'timewin', timewin + [-0.5 0.5]);


% get rippenv
fopts = filtoptdefs;
fopts.ripplehi = fopts.ripple;
fopts.ripplehi.F = [100 150 350 400];

cdat_rippenv_e123_win = contenv(contfilt(cdat_e123_win, 'filtopt', fopts.ripple));
% $$$ cdat_rippenv_e123_win = cdat_e123_win;

cdat_rippenv_smooth_e123_win = contfilt(cdat_rippenv_e123_win, 'filtopt', ...
                               mkfiltopt('filttype', 'gausswin', ...
                                         'sd_t', 0.01));

cdat_win = contresamp(cdat_rippenv_smooth_e123_win, 'resample', 1/5);

%%% grab more tets from diff channels (sync problems OK, nearest neighbor)

%%% normalize per chan. Use datarange, max peak at ripple?

[xi yi] = meshgrid(4:0.6:18, -(3:0.6:15) );
x = trodexy(:,1);
y = trodexy(:,2);

samps_win = [floor((timewin(1) - cdat_win.tstart) * cdat_win.samplerate)...
             ceil((timewin(2) - cdat_win.tstart) * cdat_win.samplerate)];


makeavi = 0;

if makeavi
  avifilename = ['~/tmp/ripp_movie' num2str(round(rand*1000))]
  avih = avifile(avifilename,...
                 'FPS',15);
end

%% set up contopt, contdrawopt, cache
eeg_win = [-1 1] * 50 ./ cdat_win.samplerate;
contopt = mkcontopt();
contdrawopt = mkcontdrawopt('drawlegend', 0);
cache = [];

fh = figure(4);

for k = samps_win(1):samps_win(2),
  ktime = cdat_win.tstart + k./cdat_win.samplerate;
  z = cdat_win.data(k,:)';
  %z = cdat_win.data(k,:)' ./ cdat_win.datarange(:,2);
  gd = griddata(x,y,double(z)',...
                xi, yi, 'linear');

  %  imagesc(gd, [0 0.12]);
  ax = subplot(4,1,1:3, 'parent', fh);
  cla(ax);
  mesh(ax,xi,yi,gd);
  hold(ax, 'on');
  plot3(ax,x,y,double(z), 'o');

  zlim(ax, [min(cdat_win.datarange(:)) max(cdat_win.datarange(:))]);
  caxis(ax, [min(cdat_win.datarange(:)) max(cdat_win.datarange(:))]);
% $$$ 
% $$$   zlim(ax, [0 1]);
% $$$   caxis(ax, [0 1]);
  caxis(ax, 'manual');
  title(ax, num2str(ktime));

  
  %% eeg plot
  
  eeg_ax = subplot(4,1,4, 'parent', fh);
  cla(eeg_ax);
  contobj = mkcont('contdata', cdat_win,...
                   'chans', 1,...
                   'timewin', ktime + eeg_win,...
                   'cache', cache,...
                   'contopt', contopt); 
  
  cache = mkcache('cache', cache,...
                  'add_obj', contobj);

  drawcont('cont', contobj,...
           'opt', contdrawopt,...
           'ax', eeg_ax,...
           'xlim', ktime + eeg_win);

  hold(eeg_ax, 'on');
  
  yl = ylim(eeg_ax);
  line([ktime ktime], yl, 'color', 'k', 'parent', eeg_ax);
  
  drawnow;
  if makeavi,
    avih = addframe(avih,fh);
  end
  pause(0.05);
end

if makeavi,
  avih = close(avih);
end
