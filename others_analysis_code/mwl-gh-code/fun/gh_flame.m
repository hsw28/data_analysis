function counts = gh_flame(varargin)

% TODO: Don't use so many points.
% You're supposed to plot one point repeatedly over itterations.

r2 = @(pos) pos(:,1).^2 + pos(:,2).^2;

f = cell(0);
f{1} = @(pos) [(pos(:,1)./2) ./ r2(pos),     (pos(:,2)./2) ./ r2(pos)];
f{2} = @(pos) [((pos(:,1)+1)./2)./ r2(pos), (pos(:,2)./2)./r2(pos)];
f{3} = @(pos) [(pos(:,1)./2)./r2(pos),     ((pos(:,2)+1)./2)./r2(pos)];

p = inputParser();
p.addParamValue('n_iter',30);
p.addParamValue('n_points',1000);
p.addParamValue('funlist',f);
p.parse(varargin{:});
opt = p.Results;
f = opt.funlist;

n_f = length(f);

xs = 2.*rand(p.Results.n_points,1)-1;
ys = 2.*rand(p.Results.n_points,1)-1;
pos = [xs,ys];

for n = 1:opt.n_iter
    your_fun = ceil(n_f.*rand(1,opt.n_points));
    for this_f = 1:n_f
        if(any(your_fun == this_f))
            this_set = (your_fun == this_f);
            pos(this_set,:) = f{this_f}(pos(this_set,:));
        end
    end
end

%r2 = repmat(pos(:,1).^2 + pos(:,2).^2,1,2);
%pos = 1./r2 .* pos;

x = pos(:,1);
y = pos(:,2);
bin = -1:0.001:1;
bin = linspace(-.01, .1, 1000);
counts = hist2(x,y,bin,bin);
imagesc(bin,bin,log(counts));
%plot(pos(:,1)',pos(:,2)','.');

%x_bin = histc(xs,[-1:0.05:1]);
%y_bin = histc(ys,[-1:0.05:1]);

%grid_counts = and(repmat(x_bin,size(y_bin,1),2), repmat(y_bin',1,size(x_bin,2)));
%imagesc(grid_counts);
%counts = grid_counts;