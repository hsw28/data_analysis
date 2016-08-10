function f = draw_track_and_fields(d,m,ind1,ind2)

calPts    = m.linearize_opts.calibrate_points;
calPtsLen = sqrt( sum (diff (calPts,2) .^ 2) );
calLen    = m.linearize_opts.calibrate_length;
px_to_m = calLen / calPtsLen;

pInd = [1:floor(numel(d.pos_info.x)/4)]; % Cut down number of points

f = plot(d.pos_info.x(pInd),d.pos_info.y(pInd),'.','MarkerSize',1,'Color',[0.6,0.7,0.75]);
hold on;

for i = [ind1,ind2]
   
    clust = d.spikes.clust{i};
    color = gh_colors(i);
    pos_at_spike_ind = find(strcmp(clust.featurenames,'out_pos_at_spike'));
    pos_x_ind        = find(strcmp(clust.featurenames,'pos_x'));
    pos_y_ind        = find(strcmp(clust.featurenames,'pos_y'));
    
    pos_ok = ~isnan(clust.data(:,pos_at_spike_ind));

    pos_x  = clust.data(:, pos_x_ind) .* px_to_m;
    pos_y  = clust.data(:, pos_y_ind) .* px_to_m;
    
    plot(pos_x(pos_ok), pos_y(pos_ok),'.','MarkerSize',10,'Color',color);
    
end

axis square;
axis equal;