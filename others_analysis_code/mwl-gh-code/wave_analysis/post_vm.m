function h = post_vm(mu,kappa,pos,varargin)

p = inputParser();
p.addParamValue('circ_rad',0.15);
p.addParamValue('pie_frac',1);
p.addParamValue('circ_stroke',[0 0 0]);
p.addParamValue('circ_fill',[1 1 1]);
p.addParamValue('pie_stroke',[0 0 0]);
p.addParamValue('pie_fill',[0 0 1]);
p.addParamValue('text',[]);
p.addParamValue('phase_data',[]);
p.parse(varargin{:});

n_arc_pt = 20;
n_circ_pt = 100;

circ_r = ones(n_circ_pt,1).*p.Results.circ_rad;
circ_theta = linspace(0,2*pi,n_circ_pt)';

arc_r = [0;ones(n_arc_pt,1).*p.Results.circ_rad.*p.Results.pie_frac;0];
if(not(kappa == -1))
    arc_theta = [0;linspace(mu-1/kappa,mu+1/kappa,n_arc_pt)';0];
else
    arc_theta = [0;linspace(0,2*pi,n_arc_pt)';0];
end

data = [];
if(~isempty(p.Results.phase_data))
    data = p.Results.phase_data;
    phase_mean = gh_circular_mean(gh_circular_mean(data,2),1); % ugly work-around for varargin bug
    p_diffs = sort(abs(gh_circular_subtract(data,phase_mean)));
    n_data = numel(data);
    pct25 = p_diffs(floor(n_data*0.25));
end


    
[circ_xx,circ_yy] = pol2cart(circ_theta,circ_r);
[arc_xx,arc_yy] = pol2cart(arc_theta,arc_r);

circ_xx = circ_xx + pos(1);
circ_yy = circ_yy + pos(2);

arc_xx = arc_xx + pos(1);
arc_yy = arc_yy + pos(2);

h = patch(circ_xx,circ_yy,p.Results.circ_fill);
hold on
plot(circ_xx,circ_yy,'-','Color',p.Results.circ_stroke);

patch(arc_xx,arc_yy,p.Results.pie_fill);
plot(arc_xx,arc_yy,'-','Color',p.Results.pie_stroke);

if(~isempty(p.Results.text))
    text(pos(1),pos(2),p.Results.text);
end

if(~isempty(data))
    mean_r = [0 p.Results.circ_rad*1.2];
    mean_t = [phase_mean, phase_mean];
    [xx, yy] = pol2cart(mean_t, mean_r);
    plot(xx+pos(1),yy+pos(2));
    pct25_r = [p.Results.circ_rad * 1.1, 0, p.Results.circ_rad*1.1];
    pct25_t = [phase_mean - pct25, 0, phase_mean + pct25];
    [xx,yy] = pol2cart(pct25_t,pct25_r);
    plot(xx+pos(1), yy + pos(2));
end

axis equal;