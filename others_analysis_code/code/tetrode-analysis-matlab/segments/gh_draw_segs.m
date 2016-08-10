function gh_draw_segs(segs, varargin)

p = inputParser();
p.addParamValue('names',[]);
p.addParamValue('ys',[]);
p.parse(varargin{:});
opt = p.Results;

if(~iscell(segs{1}))
    segs = {segs};
end

if(~iscell(opt.names) && ~isempty(opt.names))
    opt.names = {opt.names};
end

if(isempty(opt.ys))
    n_seg = numel(segs);
    opt.ys = num2cell( [(0:(n_seg-1)); (1:n_seg)]', 2);
%    opt.ys = mat2cell( [(0:(n_seg-1)); (1:n_seg)]', ones(1,n_seg),1 );
end

if(~iscell(opt.ys) && ~isempty(opt.ys))
    opt.ys = {opt.ys};
end
    
for y = 1:numel(segs)
    cellfun( @(x) lfun_draw_seg(x, opt.ys{y}), segs{y});
    if(~isempty(opt.names))
        if (y <= numel(opt.names))
            if(numel(segs{y}) > 0)
                text(segs{y}{1}(1) - 1, mean(opt.ys{y}), opt.names{y});
            end
        end
    end
end

end

function lfun_draw_seg(s,y)
    rectangle('Position',[s(1), y(1), diff(s), diff(y)],'FaceColor',[0.7 0.7 1],'EdgeColor',[0.7 0.7 1]);
end