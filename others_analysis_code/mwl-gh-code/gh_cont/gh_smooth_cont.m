function new_cdat = gh_smooth_cont(cdat, kernel_width_t,varargin)

p = inputParser();
p.addParamValue('n_passes',1);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

ts = conttimestamp(cdat);
dt = ts(2) - ts(1);

n_kernel_x = lfun_next_odd( (kernel_width_t/2 / dt) * 4 ); % 4 std devs
kernel_t_lim = (kernel_width_t / 2) * 8;
kernel_x = linspace(-kernel_t_lim, kernel_t_lim, n_kernel_x)';
%norm_coeff = 1/( (kernel_width_t/2 * sqrt(2*pi)) );
%kernel_y = norm_coeff * exp( -1 .* ( kernel_x .^ 2 )/(2* (kernel_width_t/2)^2 ) );
kernel_y = normpdf(kernel_x, 0, kernel_width_t/2);
kernel_y = kernel_y ./ sum(kernel_y);

new_cdat = cdat;

for n = 1:size(cdat.data,2)
     new_cdat.data(:,n) = conv( cdat.data(:,n), kernel_y, 'same' );
end

if(opt.draw)
    ax(1) = subplot(2,1,1);
    gh_plot_cont(cdat);
    ax(2) = subplot(2,1,2);
    gh_plot_cont(new_cdat);
    linkaxes(ax, 'x');
end

end

function c = lfun_next_odd(x)
c = ceil(x) + (1 - mod((ceil(x)),2));
end