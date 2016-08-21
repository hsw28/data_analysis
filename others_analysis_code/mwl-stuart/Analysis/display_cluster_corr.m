function display_cluster_corr(c, e, t, a)
    %plots the correlations computed by cluster_xcorr. 
    %Currently you cannot set or manipulate a threshold but that should be
    %coming soon.

    [size(c) , 0 , size(e) , 0 ,  size(t)];
    
    n = max([e;t]);
    
    delta_r = 2*pi/n;
    radian = 0:delta_r:2*pi-delta_r;
    
    radius = ones(1, n);
    radius(~ismember(1:n, unique([e;t])))=nan;
    
       
   
    [x,y] = pol2cart(radian, radius);
        
    corr = define_corr(c);
    
    f = handle(get(a, 'Parent'));
    hold(a,'on');
    for i=1:size(c,1)
        if (corr(i)>2)
            line([x(e(i)) x(t(i))], [y(e(i)) y(t(i))], 'LineWidth', corr(i), 'Parent', a);
        end
    end
    plot(x,y,'o', 'MarkerSize', 35, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'Parent',a);
    font_size = 18;
    for i=1:size(radius,2)
        t =  text(x(i), y(i), num2str(i), 'Parent', a);
        set(t, 'FontSize', font_size,'HorizontalAlignment', 'center', 'color', 'y');
        set(t, 'VerticalAlignment', 'middle');
    end
        
    set(f, 'Position', [500 500 600 600], 'color','w');
    set(a, 'YTick', [], 'XTick', [], 'Box', 'off');
    %set(a, 'XColor', 'w', 'YColor', 'w');
    axis(a, 'off');
    
    function corr = define_corr(c)
        corr = sum(c,2);
        corr = floor(corr/2000);
    end
end