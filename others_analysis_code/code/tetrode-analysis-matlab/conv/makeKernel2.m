function k = makeKernel2(stdX,stdY,rangeX,rangeY,dx,dy)
% k = makeKernel2(stdX,stdY,rangeX,rangeY,dx,dy)
% Make k a gaussian kernel centered in the middle
% of the array. rangeX and rangeY are the one-sided
% extent of the kernel, in the units of the problem domain
% dx and dy are problem-domain units per matrix step

sizeX = lfun_nearest_n_point_five(rangeX / dx);
sizeY = lfun_nearest_n_point_five(rangeY / dy);
xs = -(sizeX*dx) : dx : (sizeX*dx);
ys = -(sizeY*dy) : dy : (sizeY*dy);

varX = stdX ^ 2;
varY = stdY ^ 2;

[XX,YY] = meshgrid(xs,ys);
k = exp( -1 .* ( (XX.^2)/(2*varX) + (YY.^2)/(2*varY) ));
k = k ./ sum(sum(k));


end

function y = lfun_nearest_n_point_five(x)

y = floor(x) + 1/2;

end