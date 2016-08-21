function l = my_rectangle_edges(x,y,dx,dy,line_style, color1, color2, width, haxes)

   l =  line([x x ], [y y+dy ],'LineStyle', line_style, 'Color', color1, 'Parent', haxes, 'linewidth', width);    
   l =  line([x+dx x+dx ], [y y+dy ],'LineStyle', line_style, 'Color', color2, 'Parent', haxes, 'linewidth', width);    

end