function anim_dists_draw(h, pos, pref_mat, strains_mat, floor_size)

line_offset = 0.01;

n_point = numel(pos);


for m = 1:n_point
    for n = 1:n_point
        if(n ~= m)
            %pos(m)
            %pos(n)
            %abs(pos(m) - pos(n))
            this_level = max([(abs(pos(m) - pos(n)) / abs(floor_size)),1]);
            this_level = 1;
            if(strains_mat(m,n) < 0)
                this_color = [0,0, this_level];
            elseif(strains_mat(m,n) > 0)
                this_color = [this_level, 0, 0];
            else
                this_color = [0, 0, 0];
            end
            the_sign = (m < n) * 2 - 1;
            this_x = [real(pos(m)), real(pos(n))] + 0.1*(the_sign*line_offset/real(floor_size));
            this_y = [imag(pos(m)), imag(pos(n))];
            %this_color
            plot(this_x,this_y,'Color',this_color);
            hold on;
        end
    end
    plot(real(pos(m)),imag(pos(m)),'kO');
    text(real(pos(m)),imag(pos(m)),num2str(m),'FontSize',20);
    xlim([0 real(floor_size)]);
    ylim([0 imag(floor_size)]);
end
hold off;