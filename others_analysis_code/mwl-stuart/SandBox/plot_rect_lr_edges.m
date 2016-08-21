function l = plot_rect(x, y, c1, c2, width, haxes)

   l =  line([x(1) x(1)], [y(1) y(2)],'LineStyle', '-', 'Color', c1, 'Parent', haxes, 'linewidth', width);    
   l =  line([x(2) x(2)], [y(1) y(2)],'LineStyle', '-', 'Color', c2, 'Parent', haxes, 'linewidth', width);    

end