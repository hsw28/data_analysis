function combined_segs = gh_combine_segs(varargin)

p = inputParser();
p.addParamValue('cdat',[]);
p.addParamValue('criteria',[]);
p.addParamValue('names',[]);
p.addParamValue('fold_fn',@(x) x);
p.addParamValue('smooth_s',0);
p.addParamValue('bridge_max_gap',0);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

if (nargin(opt.fild_n) ~= numel(data)) || (numel(data) ~= numel(criteria))
    error('gh_combine_segs:args_mismatch',...
        ['data, criteria, and fold_fn args must be the same.  They are ', ...
        num2str(numel(opt.data)), num2str(numel(opt.criteria)), 
        ' and ', num2str(nargin(opt.fold_fn))]);
end



segs_cell = cellfun(@(x,y) gh_signal_to_segs(x,y), opt.cdat, opt.criteria,'UniformOutput', false);


combined_segs = opt.fold_fn(segs_cell{:});
combined_segs = gh_bridge_segs(combined_segs, opt.bridge_max_gap);

if(opt.draw)
    for n = 1:numel(opt.cdat)
        ax(n) = subplot(numel(opt.cdat), 1, n);
        gh_plot_cont(opt.cdat{n});
        segs = gh_signal_to_segs( opt.cdat{n}, opt.criteria{n} );
        gh_draw_segs(segs);
        if(~isempty(opt.names))
            ylabel(opt.names{n});
        end
    end
    linkaxes(ax,'x');
end