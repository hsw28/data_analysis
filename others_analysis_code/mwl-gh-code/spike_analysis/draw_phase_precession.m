function ZZ = draw_phase_precession(clust, varargin)

p = inputParser();
p.addParamValue('position',[10,10,600,300]);
p.addParamValue('xlim',[0,4]);
p.addParamValue('ylim',[0,4*pi]);
p.addParamValue('sd_x',0.05);
p.addParamValue('sd_p', 0.4); %  or: 8*pi * 0.2/4.0);
p.addParamValue('img_downsample',6);
p.addParamValue('flip_inbound',true);
p.addParamValue('contour_level',2);
p.addParamValue('stack','horizontal',@(x) any(strcmp(x,{'vertical','horizontal'})));
p.addParamValue('field_direction','bidirect',@(x) any(strcmp(x,{'bidirect','outbound','inbound'})));
p.addParamValue('clim',[]);
p.addParamValue('file_path',[]);
p.addParamValue('ind',[]);
p.addParamValue('draw',true);
p.parse(varargin{:});
opt = p.Results;

if(strcmp('horizontal',opt.stack))
    opt.position(3) = 2*opt.position(3);
    opt.xlim(2)     = 2*opt.xlim(2);
elseif(strcmp('vertical',opt.stack))
    opt.position(4) = 2*opt.position(4);
    opt.ylim(1)     = -1*opt.ylim(2);
end

n_x = opt.position(3) / opt.img_downsample;
n_y = opt.position(4) / opt.img_downsample;

xs = linspace(opt.xlim(1), opt.xlim(2), n_x);
ys = linspace(opt.ylim(1), opt.ylim(2), n_y);

[XX,YY] = meshgrid(xs,ys);

out_pos_ind = find(strcmp(clust.featurenames,'out_pos_at_spike'),1);
in_pos_ind  = find(strcmp(clust.featurenames,'in_pos_at_spike' ),1);
phase_ind   = find(strcmp(clust.featurenames,'theta_phase'     ),1);
if(isempty(out_pos_ind) || isempty(in_pos_ind))
    error('draw_phase_precession:no_out_pos_or_in_pos_feature','Clust passed in doesn''t have out_pos_at_spike or in_pos_at_spike field');
end
if(isempty(phase_ind))
    error('draw_phase_precossion:no_phase_feature','Clust passed in doesn''t have theta_phase field');
end

out_xs = clust.data(:,out_pos_ind)';
in_xs  = clust.data(:,in_pos_ind )';
if(opt.flip_inbound)
    if(strcmp('horizontal',opt.stack))
        in_xs = opt.xlim(2)/2 - in_xs;
    else
        in_xs = opt.xlim(2) - in_xs;
    end
end
ps     = mod(clust.data(:,phase_ind)',2*pi);

out_ok = ~isnan(out_xs) & (~isnan(ps));
in_ok  = ~isnan(in_xs)  & (~isnan(ps));
if(strcmp('outbound',opt.field_direction))
    in_ok = logical(zeros(size(in_ok)));
end
if(strcmp('inbound',opt.field_direction))
    out_ok = logical(zeros(size(out_ok)));
end

if(strcmp('vertical',opt.stack))
    poses = [out_xs(out_ok),out_xs(out_ok),in_xs(in_ok),in_xs(in_ok)];
    phases = [ps(out_ok), ps(out_ok) + 2*pi, ps(in_ok) - 2*pi, ps(in_ok) - 4*pi];
elseif(strcmp('horizontal',opt.stack))
    poses = [out_xs(out_ok),out_xs(out_ok),in_xs(in_ok) + opt.xlim(2)/2, in_xs(in_ok) + opt.xlim(2)/2];
    phases = [ps(out_ok), ps(out_ok) + 2*pi, ps(in_ok), ps(in_ok) + 2*pi];
else
    if(~strcmp('overlap',opt.stack))
        warning('draw_phase_precession:unknown stack param',['Didn''t understand ''stack'':', opt.stack,' so using ''overlap''']);
    end
    poses = [out_xs(out_ok),out_xs(out_ok),in_xs(in_ok),in_xs(in_ok)];
end

ZZ = arrayfun(@(x,y) lfun_eval_point(x,y,poses,phases,opt), XX,YY);

if(~isempty(opt.clim))
    clim = opt.clim;
else
    clim = [0,max(max(ZZ))];
end

ZZ = (ZZ - clim(1)) / diff(clim);
ZZ(ZZ < 0) = 0;
ZZ(ZZ > 1) = 1;

%[c2,hc2] = contour(ZZ,opt.contour_level);

if(opt.draw)
    f = figure('Position',opt.position);
    image([xs(1),xs(end)],[ys(1),ys(end)],repmat(ZZ,[1,1,3]));
    ylabel(['Trode:', clust.comp]);
    set(gca,'YDir','normal');
    
    if(~isempty(opt.file_path))
        % TODO: replace with imsave?  saveas seems to set bg color to white :S
        saveas(f, [opt.file_path,'/', clust.comp, '-', str_of_int(opt.ind), '.tif']);
        close(f);
    end
end

function s = str_of_int(ind)
s = num2str(ind);
if(numel(s) == 1)
    s = ['0',s];
end

function sumval = lfun_eval_point(x,y,poses,phases,opt)
sumval = sum(exp( (-1/2) .* (((poses - x)/opt.sd_x).^2 + ((phases - y)/opt.sd_p).^2)));