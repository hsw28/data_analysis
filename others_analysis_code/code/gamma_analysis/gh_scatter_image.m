function f = gh_scatter_image(x_data,y_data,varargin)

p = inputParser();
p.addParamValue('x_edges',linspace(min(x_data), max(x_data), 50));
p.addParamValue('y_edges',linspace(min(y_data), max(y_data), 50));
p.parse(varargin{:});

x_edges = p.Results.x_edges;
y_edges = p.Results.y_edges;

n_pts = numel(x_data);

[xcounts, x_ind] = histc(x_data,x_edges);
[ycounts, y_ind] = histc(y_data,y_edges);

counts_2d = zeros(numel(y_edges),numel(x_edges));

for m = 1:n_pts
    if(and((x_ind(m) > 1),y_ind(m) > 1))
        counts_2d(y_ind(m),x_ind(m)) = counts_2d(y_ind(m),x_ind(m)) + 1;
    end
end

imagesc([x_edges(1),x_edges(end)],[y_edges(1),y_edges(end)],counts_2d);
axis xy;
colormap hot;
