function l = plot_rect(x, y, color1, width, haxes)

   l =  line([x(1) x(1) x(2) x(2) x(1) ], [y(1) y(2) y(2) y(1) y(1) ],'LineStyle', '-', 'Color', color1, 'Parent', haxes, 'linewidth', width);    

end