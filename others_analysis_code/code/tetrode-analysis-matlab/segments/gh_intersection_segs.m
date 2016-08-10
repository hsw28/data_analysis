function new_s = gh_intersection_segs(s1,s2,varargin)

%  |||||    ||||    ||||||||||   ||    ||||  s1
%    ||   ||||         |||||||||||   |       s2
%
%    ||     ||         |||||||   |           new_s

p = inputParser();
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

s1 = reshape(s1,1,[]);
s2 = reshape(s2,1,[]);

ss = cellfun(@(x) lfun_intersect_all_against_one(s1, x), s2,'UniformOutput',false);

num_segs = cellfun(@(x) numel(x), ss);
ind_start = 1 + [0, cumsum(num_segs)];
new_s = cell(1, sum(num_segs));
for n = 1:numel(ss)
    this_range = ind_start(n) : (ind_start(n) + num_segs(n) - 1);
    new_s(this_range) = ss{n};
%    for m = 1:numel(ss{n})
%        new_s(this_range(m)) = ss{m};
%    end
end

if(opt.draw)
    title([num2str(numel(new_s)), ' segs in intersection']);
    %cellfun(@(x) lfun_draw_seg(x, [0.6 1.4]), s1); 
    %cellfun(@(x) lfun_draw_seg(x, [1.6,2.4]), s2);
    %cellfun(@(x) lfun_draw_seg(x, [2.6,3.4]), new_s);
    gh_draw_segs({s1,s2,new_s}, 'names', {'s1','s2','new_s'});
end
end

function new_s = lfun_intersect_all_against_one(s, seg)
%  |||||    ||||    ||||||||||   ||    ||||
%         ||||

% List of s's that start before target ends, and end after target starts
possibles = cellfun(@(x) (x(1) < seg(2) && x(2) > seg(1)),s);

new_s = cell(1,sum(possibles));
p = s(logical(possibles));

for n = 1:sum(possibles)
    new_s{n} = [ max([p{n}(1), seg(1)]), min([p{n}(2), seg(2)]) ];
end


end

function lfun_draw_seg(s, y)
    rectangle('Position',[ s(1), y(1), diff(s), diff(y) ]);
end