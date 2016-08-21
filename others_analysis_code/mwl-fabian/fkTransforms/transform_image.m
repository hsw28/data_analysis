function [Timg, Tx, Ty] = transform_image(img, rot, scale, transl)
%TRANSFORM_IMAGE apply transformation to image
%
%  [timg,tx,ty]=TRANSFORM_IMAGE(img,angle,scale,offset) returns the
%  transformed image, which has been rotated around its center by angle
%  degrees, scaled by a factor of scale and translated by offset. Both
%  scale or offset can be scalars for uniform transformation in x and y
%  dimensions or two element vectors for non-uniform transformation in
%  the two dimensions. The output is the transformed image timg, and the
%  x and y extents of the new image.
%

%  Copyright 2005-2008 Fabian Kloosterman


%center of rotation
sz = fliplr( size(img) ) - 1;
c = sz ./ 2;
%create identity matrix
T = T2D_identity();
%rotate
T = T2D_rotate( rot*pi/180, T, c );
%scale
T = T2D_scale( scale, T);
%translate
T = T2D_translate( transl , T);
%make matlab affine transformation matrix
T = maketform('affine', T');
%transform image
[Timg, Tx, Ty] = imtransform( img, T, 'UData', [0 sz(1)], 'VData', [0 sz(2)]); %, 'XData', [0 328], 'YData', [0 254]);