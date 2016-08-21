%% Test vertical stack in grayscale
img = 1-repmat(r.pdf{1},[1,1,3]);
img = [img; 1-repmat(r.pdf{2},[1,1,3])];
img = [img; 1-repmat(r.pdf{3},[1,1,3])];
img = [img; 1-repmat(r.pdf{4},[1,1,3])];

figure;
imagesc(img)

%% Test directional vertical stack

img1(:,:,1) = r.pdf{1};
img1(:,:,3) = r.pdf{2};

img2(:,:,1) = r.pdf{3};
img2(:,:,3) = r.pdf{4};

img = [img1; img2];

figure; imagesc(img);

%% test JET vertical stack
img = r.pdf{1};
img = [img; r.pdf{2}];
img = [img; r.pdf{3}];
img = [img; r.pdf{4}];

figure;
imagesc(img);

%% 
figure; imagesc(r.pdf);

