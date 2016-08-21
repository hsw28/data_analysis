
%% Simple debugable setup
clear;

mat = ones(32,10);

for i = 1:size(mat,1)
    for j = 1:size(mat,2)
        mat(i,j) = i*10;
    end
end

A = mat;
B = A;
D = randi([0, size(A,1)-1], [1, size(A,2)]);
[m, n] = size(A);
nIter = 1;

%% produce graphic for Matlab File Exchange
D = randi([0 m-1], [1,n]);
[B D] = col_circ_shift(A, D);

figure;
ax(1) = subplot(121);
imagesc(A);
ax(2) = subplot(122);
imagesc(B);

for i = 1:n-1
    line([i i]+.5, [0 m]+.5, 'color', 'k', 'parent', ax(1), 'linewidth', 2);
    line([i i]+.5, [0 m]+.5, 'color', 'k', 'parent', ax(2), 'linewidth', 2);
end

%% Large benchmarcking setup
clear;
sz = 3000;
nIter = 100;
A = rand(sz,sz);
B = A;
D = randi([0, size(A,1)-1], [1, size(A,2)]);
[m, n] = size(A);


%% Loop baseline
tic;
for iter = 1:nIter
    B = A;
    for i = 1:size( A,2 );
       B(:,i) = circshift( A(:,i), [D(i), 0] );
    end
end
dt = toc;
fprintf('Elapsed time: %0.5g seconds\n', dt);
res.loop = B;
%% test 1 - Zroth
B = A;
tic;

for iter = 1:nIter
    for i = (1 : n)
        B(:, i) = [A((m - D(i) : m), i); A((1 : m - D(i) - 1), i)];
    end
    
end
dt = toc;
fprintf('Elapsed time: %0.5g seconds\n', dt);
res.zroth1 = B;

%% test 1 - col_circ_shift
B = A;
tic;

for iter = 1:nIter
    for i = (1 : n)
        B(:, i) = [A((m - D(i) : m), i); A((1 : m - D(i) - 1), i)];
    end
    
end
dt = toc;
fprintf('Elapsed time: %0.5g seconds\n', dt);
res.col_circ_shift = B;


%% test 2 - Ansari
tic;
for iter = 1:nIter
    B = arrayfun(@(i) circshift(A(:, i), [D(i), 0]), 1:n, 'UniformOutput', false);
    B = cell2mat(B);
end
dt = toc;
fprintf('Elapsed time: %0.5g seconds\n', dt);
res.ansari = B;

%% test 3 - Zroth 2
tic;
for iter = 1:nIter
    mtxLinearIndices ...
        = bsxfun(@plus, ...
             mod(bsxfun(@minus, (0 : m - 1)', D), m), ...
             (1 : m : m * n));
    C = A(mtxLinearIndices);
end

dt = toc;
fprintf('Elapsed time: %0.5g seconds\n', dt);
res.zroth2 = B;

% Code originally inspired by this discussion http://stackoverflow.com/q/11584711

%%

a = ones(10000,1);




