function f = sv_place_cell_pair(d,m,okPair,varargin)
% f = SV_PHASE_PAIR (sdat, ['rat_conv_table',conv_table], ['m',blue_cell_index],
%                          ['n',green_cell_index],['draw_extras',bool],
%                          ['trode_groups', trode_groups], ['overlay', bool],
%                          ['draw_phase_extents',true])
% Draws spikes of two units at their track positions (x) and theta phase (y)
% Units input must be in an sdat struct that has gone through assign_field
% and assign_theta_phase
%
% Flip blue cell id with LEFT and RIGHT arrow keys.  Green cell with UP and DOWN

p = inputParser();
p.addParamValue('ok_directions',{'outbound','inbound'});
p.addParamValue('m',1,@isreal);
p.addParamValue('n',2,@isreal);
p.parse(varargin{:});
opt = p.Results;

[~,~,fieldDists,anatomicalDists,xCorrDists,fieldCells,fields,xcorr_r,xcorr_mat] = ...
    full_xcorr_analysis(d,m,'ok_pair',okPair,'ok_directions',opt.ok_directions,'draw',false);


pcNames = cmap(@(x) x.name, d.spikes.clust);
inds = cellfun(@(x) find( strcmp(pcNames,x),1,'first'), fieldCells);
place_cells = d.spikes;
place_cells.clust = place_cells.clust(inds);
d.spikes = place_cells;

%xcorr_r( isnan(xcorr_r) ) = 0;
%xcorr_r = xcorr_r .* (1 - eye(size(xcorr_r,1)));

data.m               = p.Results.m;
data.n               = p.Results.n;
data.d               = d;
data.sdat            = place_cells;
data.fields          = fields;
data.fieldCells      = fieldCells;
data.fieldDists      = fieldDists;
data.anatomicalDists = anatomicalDists;
data.xCorrDists      = xCorrDists;
data.xCorrR          = xcorr_r;
data.xCorrMat        = xcorr_mat;

data.f = figure('Position',[50 50 400 300],'KeyPressFcn',@localfn_figure_keypress);

data.opt = opt;
data.rat_conv_table = d.rat_conv_table;
guidata(data.f,data);
f = data.f;

localfn_plots(f);

end

function localfn_plots(f)
  dat = guidata(f);
  disp(['m: ', dat.fieldCells{dat.m}]);
  disp(['n: ', dat.fieldCells{dat.n}]);
  subplot(2,4,1); localfn_plot_trode_pos(dat.m,dat.n,dat.d);
  subplot(2,4,3); localfn_plot_xcorr(dat.m,dat.n,dat.xCorrMat,dat.xCorrDists);
  subplot(2,4,2); localfn_plot_field(dat.m,dat);
  subplot(2,4,4); localfn_plot_field(dat.n,dat);
  subplot(2,4,5); localfn_plot_mat(dat.m,dat.n,...
      max(-50,real(log(dat.xCorrR))));
  xlabel('xcorr');
  subplot(2,4,6); localfn_plot_mat(dat.m,dat.n,dat.fieldDists); xlabel('field');
  subplot(2,4,7); localfn_plot_scatter(dat.m, dat.n, ...
      dat.fieldDists, dat.xCorrDists,dat.xCorrR);
end

function localfn_plot_mat(m,n,mat)
  mat(isnan(mat)) = 0;
  matMax = max(max(mat(~isnan(mat))));
  matMin = min(min(mat(~isnan(mat))));
  mask = matMin*ones(size(mat));
  mask(m,:) = matMax;
  mask(:,n) = matMax;
  nRow = size(mat,1);
  nCol = size(mat,2);
  mask(m,(max(1, (min(nRow,[-2:2]+n))))) = matMin;
  mask((max(1,(min(nCol,[-2:2]+m)))),n) = matMin;
  imagesc(max(mat,mask));
end

function localfn_plot_scatter(m,n,fieldDists,tDists,xCorrR)
    fieldDistsFlat = reshape(fieldDists,1,[]);
    tDistsFlat     = reshape(tDists,1,[]);
    xCorrRFlat     = reshape(xCorrR,1,[]);
    hold off;
    plot(fieldDistsFlat,tDistsFlat,'.');
    hold on;
    if (~isnan(fieldDists(m,n)) && ~isnan(tDists(m,n)));
        plot(fieldDists(m,n),tDists(m,n),'r.','MarkerSize',32);
        disp(['field: ', num2str(fieldDists(m,n)), ...
              ', time:', num2str(tDists(m,n))]);
    else
        disp([num2str(m),', ',num2str(n),': nan']);
    end
    xlim([-1,1]); ylim([-0.1,0.1]);
end

function localfn_figure_keypress(src,eventdata)
data = guidata(src);

if strcmp(eventdata.Key,'rightarrow')
    data.n = data.n + 1;
elseif strcmp(eventdata.Key, 'leftarrow')
    data.n = data.n - 1;
elseif strcmp(eventdata.Key, 'uparrow')
    data.m = data.m - 1;
elseif strcmp(eventdata.Key, 'downarrow')
    data.m = data.m + 1;
end

guidata(data.f,data);
localfn_plots(data.f);
end

function localfn_plot_trode_pos(m,n,d)
  hold off;
  draw_trodes(d.rat_conv_table,'trode_groups',d.trode_groups,...
      'highlight_names',...
      {d.spikes.clust{m}.name,d.spikes.clust{n}.name});
end

function localfn_plot_field(n,dat)
  xs = dat.d.spikes.clust{n}.field.bin_centers;
  cellOut = dat.d.spikes.clust{n}.field.out_rate;
  cellIn  = dat.d.spikes.clust{n}.field.in_rate;
  r = dat.fields{n};
  fieldOut = r(1:numel(xs));
  fieldIn  = r(end:-1:(numel(xs)+1));
  plot(xs,cellOut);
  hold on;
  plot(xs,-1 * cellIn);
  area(xs,fieldOut);
  area(xs,-1* fieldIn);
  hold off;
end

function localfn_plot_xcorr(m,n,xcMat,xcDists)
  nElem = numel(xcMat{m,n});
  xs = linspace (-nElem/2, nElem/2, nElem) .* 0.002;
  hold off;
  if(sum(isnan(xcMat{m,n})) == 0 && numel(xcMat{m,n}) == numel(xs))
      plot(xs,xcMat{m,n});
      hold on;
      %plot(xcDists(m,n), max(xcMat{m,n}));
      maxInds = find(xcMat{m,n} == max(xcMat{m,n}));
      if (numel(maxInds) > 0)
          plot( [xs(maxInds(1)),xs(maxInds(1))], [0,max(xcMat{m,n})],'r');
      else
          plot(0,0);
      end
  else
      plot(0,0);
  end
end