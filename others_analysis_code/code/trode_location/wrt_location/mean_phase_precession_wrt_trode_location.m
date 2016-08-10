function mean_phase_precession_wrt_trode_location(data, trode_i, trode_j, wrt_opt, varargin)

p = inputParser();
p.addParamValue('phase_marker',2*pi);
p.addParamValue('phase_rotate',2*pi/2);
p.addParamValue('pos_marker', []);
p.parse(varargin{:});
opt = p.Results;

trode_names = unique(cellfun( @(x) x.comp, data.clust,'UniformOutput',false ));
one_clust_per_trode = sdat_keep_one_cell_per_trode(data);

trode_xy = mk_trodexy(one_clust_per_trode, wrt_opt.rat_conv_table);

n_trodes = size(trode_xy,1);

for i = 1:n_trodes
    
    this_comp = trode_names{i};
    this_trode_xy = trode_xy(i,:);
    this_data = sdatslice(data,'trodes', {this_comp});
    [pos,phase,p_centers,m_phase] = mean_phase_precession(this_data,'scale_to_field',true);
    phase = phase + opt.phase_rotate;
    phase = mod(phase - 0, 2*pi);
    m_phase = m_phase + opt.phase_rotate;
    m_phase = mod(m_phase,2*pi);
    
    x_data = lfun_x_transform(pos, this_trode_xy, wrt_opt);
    y_data = lfun_y_transform(phase,this_trode_xy,wrt_opt);
    
    plot(x_data,y_data,'.','MarkerSize',1);
    hold on;
    plot(lfun_x_transform(p_centers,this_trode_xy,wrt_opt), ...
         lfun_y_transform(mod(m_phase,2*pi),  this_trode_xy,wrt_opt),'k');
    plot( lfun_x_transform([0,1], this_trode_xy, wrt_opt), ...
          lfun_y_transform([1,1] .* opt. phase_marker, this_trode_xy, wrt_opt));
    
end

end

function xt = lfun_x_transform(x,this_trode_xy, opt)
    xt = this_trode_xy(1) + x .* diff(opt.sub_x_size);
end

function yt = lfun_y_transform(y,this_trode_xy, opt)
    yt = this_trode_xy(2) + y / (2*pi) * diff(opt.sub_y_size);
end