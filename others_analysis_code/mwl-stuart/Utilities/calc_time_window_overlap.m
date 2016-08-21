function [idx1 idx2] = calc_time_window_overlap(A, B)

overlap = @(x, y)y(:, 1) < x(:, 2) & y(:, 2) > x(:, 1);
[tmp1, tmp2] = meshgrid(1:size(A, 1), 1:size(B, 1));
M = reshape(overlap(A(tmp1, :), B(tmp2, :)), size(B, 1), [])';
[idx1, idx2] = find(M);

% 
% idx1 = [];
% idx2 = [];
% for i=1:size(win1,1)
%     for j=i:size(win2,1)
%         overlap = @(x, y)y(:, 1) < x(:, 2) & y(:, 2) > x(:, 1);
%         o = win(i,1) <= win(2seg_overlap(win1(i,:), win2(j,:));
%         if o~=overlap(win(i,L
%             idx1(end+1) = i;
%             idx2(end+1) = j;
%         end
%     end
% end
% end