function l = plot_rect_edges(x, y, c, width, haxes)

  
  l(4) = line([x(1) x(2)], [y(1) y(1)],'LineStyle', '-', 'Color', c(4), 'Parent', haxes, 'linewidth', 1, 'linestyle', '--');    
  l(2) = line([x(1) x(2)], [y(2) y(2)],'LineStyle', '-', 'Color', c(3), 'Parent', haxes, 'linewidth', 1, 'linestyle', '--');     
  l(3) = line([x(1) x(1)], [y(1) y(2)],'LineStyle', '-', 'Color', c(1), 'Parent', haxes, 'linewidth', width);    
  l(1) = line([x(2) x(2)], [y(1) y(2)],'LineStyle', '-', 'Color', c(2), 'Parent', haxes, 'linewidth', width);    

end