function img = scatter_image(x,y,varargin)
%SCATTER_IMAGE produces an image from a scatter plot of x an y points
%
% img = scatter_image(x_points, y_points) produces a scatter plot from the
% data using 21 bins
%
% img = scatter_image(..., x_bins, y_bins) produces image using the
% specified bins
%
% Based upon gh_scatter_image written by Greg Hale.
% This version was written by Stuart Layton August 20, 2009

if numel(varargin)==2
    x_edges = varargin{1};
    y_edges = varargin{2};
else
    x_edges = min(x):(max(x)-min(x))/20:max(x)+(max(y)-min(y))/20;
    y_edges = min(y):(max(y)-min(y))/20:max(y)+(max(y)-min(y))/20;
end

n_pts = numel(x);

[xcounts, x_ind] = histc(x,x_edges);
[ycounts, y_ind] = histc(y,y_edges);
unique(x_ind');
unique(y_ind');
size(unique(x_ind))
size(unique(y_ind))

img = zeros(numel(y_edges),numel(x_edges));
size(img)
for m = 1:n_pts
    if x_ind(m) > 1 && y_ind(m) > 1
        img(y_ind(m),x_ind(m)) = img(y_ind(m),x_ind(m)) + 1;
    end
end


