function l = my_rectangle(x,y,dx,dy,line_style, color, width, haxes)

   l =  line([x x x+dx x+dx x], [y y+dy y+dy y y],'LineStyle', line_style, 'Color', color, 'Parent', haxes, 'linewidth', width);    

end