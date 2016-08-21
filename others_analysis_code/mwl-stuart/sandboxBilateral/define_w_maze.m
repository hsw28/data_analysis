function [pts lineOrder] =  define_w_maze(cx, cy, w, h, rotation)

pts = zeros(6, 4);

pts(1,1:2) = [-1,  1];
pts(2,1:2) = [-1, -1];
pts(3,1:2) = [1,  -1];
pts(4,1:2) = [1,  1];
pts(5,1:2) = [0,  -1];
pts(6,1:2) = [0, 1];



scaleTransform = makehgtform('scale', [w/2, h/2, 1]);
rotateTransform = makehgtform('zrotate', rotation);

pts = pts * scaleTransform;
pts = pts * rotateTransform;

pts = pts(:,1:2);

%shift the pts
pts(:,1) = pts(:,1) + cx;
pts(:,2) = pts(:,2) + cy;

lineOrder = [1, 2, 3, 5;
             2, 3, 4, 6];
% figure;
% 
% for i = lineOrder
%     line( pts(i,1), pts(i,2) );
% end
% 


