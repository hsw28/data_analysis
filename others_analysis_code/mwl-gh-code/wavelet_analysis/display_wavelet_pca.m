function display_wavelet_pca(eeg_r,pca_coeff,pca_score,pca_latent,comp_pca_opt,rat_conv_table,varargin)

p = inputParser;
p.addParamValue('prin_comp_ind',1);
p.addParamValue('win_xlim',[0 200]);
p.addParamValue('win_ylim',[-0.1 0.2]);
p.addParamValue('win_size',[0.5 0.5]);
p.addParamValue('wavelet_coefs',[]);
p.parse(varargin{:});
opt = p.Results;

this_prin_comp = pca_coeff(:,opt.prin_comp_ind)';

%figure;
%subplot(2,1,1);
ax(1) = axes('XLim',[1.5 5.5],'YLim',[-6.5 -2.5]);
%ax(1) = axes;
view(2);
%axis equal;
hold on;

n_trode = size(pca_coeff,2)/length(comp_pca_opt.spec_freqs);
if(~n_trode == size(eeg_r.raw.data,2))
    error('Sanity check fail at n_trode calculation');
end

%if(strcmp(pca_comp_opt,

for n = 1:n_trode
    
    this_princomp_ind = (1:length(comp_pca_opt.spec_freqs)) + (n-1)*length(comp_pca_opt.spec_freqs);
    t(n) = hgtransform('Parent',ax(1));
    x_center = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ml',rat_conv_table);
    y_center = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ap',rat_conv_table);
    
    this_h = [];
    this_h(end+1) = plot(comp_pca_opt.spec_freqs,this_prin_comp(this_princomp_ind),'.',...
    'Parent',t(n));
    this_h(end+1) = plot(opt.win_xlim,[0 0],'Parent',t(n));
    
    xscale = opt.win_size(1)/diff(opt.win_xlim);
    yscale = opt.win_size(2)/diff(opt.win_ylim);
    STxy = makehgtform('scale',[xscale,yscale,1],'translate',[x_center/xscale,y_center/yscale,1]);
    set(t(n),'Matrix',STxy);
    drawnow;
end
    