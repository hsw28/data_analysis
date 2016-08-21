function [me]  = calc_decoding_stats_by_lap(input, output)

%warning('The mutual information calculation breaks down as n gets very small. Short laps will yield invalid estimates');
laps = exp_lapify(input.exp.(input.ep).pos);

% filter laps based on decoding range
lap_time = diff(laps(:,1:2)')';
good_laps = lap_time>3;

laps = laps(good_laps, :);
laps = laps(laps(:,1)>=input.d_range(1),:);

me = [];

for i=1:size(laps,1)
    ind = output.tbins>=laps(i,1) & output.tbins<=laps(i,2);
    tbins = output.tbins(ind);
    est = {};
    for j= 1:numel(output.est)
        est{j} = output.est{j}(:,ind);
    end
 %   mi(i,:) = calc_recon_mi(est, tbins, output.pbins, input.exp.(input.ep).pos);
    [~, me(i,:)] = calc_recon_errors(est, tbins, output.pbins, input.exp.(input.ep).pos);
end


% %%
% figure;
% title('Mutual Information');
% 
% line([2 4.5], [2 4.5], 'color', 'k', 'linewidth', 2);
% line(mi(:,1), mi(:,5), 'linestyle', '.', 'color', 'r', 'markersize', 10); 
% 
% xlabel('Clusterless');
% ylabel('Cell Identify');
% 
% 
% figure;
% title('Median Error');
% 
% line([0 .25], [0 .25], 'color', 'k', 'linewidth', 2);
% line(me(:,1), me(:,5), 'linestyle', '.', 'color', 'r', 'markersize', 10); 
% 
% xlabel('Clusterless');
% ylabel('Cell Identify');