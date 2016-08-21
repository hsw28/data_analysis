function [lp, sects, sectIdx] = dset_correct_linear_position(linearposition, sections,  sections_index)

x = 1:numel(linearposition);
y = linearposition;
sectIdx = sections_index;

f = figure('Position', [1615 669 1899 420]) ;
a = axes('Position', [.0152 .0833 .9817 .8833]);

l1 = line(x(sectIdx==1), y(sectIdx==1), 'color', 'g', 'marker', '.', 'linestyle', 'none');
l2 = line(x(sectIdx==2), y(sectIdx==2), 'color', 'b', 'marker', '.', 'linestyle', 'none');
l3 = line(x(sectIdx==3), y(sectIdx==3), 'color', 'k', 'marker', '.', 'linestyle', 'none');


userHappy = 'No';
tempSection = sectIdx;

while ~strcmp('Yes', userHappy)
   [x1,y1,x2,y2] = draw_dynamic_rectangle(gca);
   polyX = [x1 x1 x2 x2 x1];
   polyY = [y1 y2 y2 y1 y1];
   pointIdx = find(inpolygon(x,y,polyX, polyY));
  
   xTemp = x(pointIdx);
   yTemp = y(pointIdx);
        
   % perform basic correction on the points
   
   for idx = 1:numel(yTemp)
      switch sections_index(pointIdx(idx))
          case 1
 %            yTemp(idx) = max(sections{1}) + ( yTemp(idx) - max(sections{1}) );
              tempSection(idx) = 1;
          case 2
%             yTemp(idx) = yTemp(idx) - max(sections{1});
              tempSection(idx) = 2;
          case 3
              yTemp(idx) = yTemp(idx) - max(sections{2}); + max(sections{1})% - max(sections{2});
              tempSection(pointIdx(idx)) = 2;
      end    
   end
   lTemp = line(xTemp, yTemp, 'linestyle', 'none', 'marker', '.', 'color', 'r');
   

   goodMove = questdlg('Was that a good fix?', 'Good Fix?' ,'No');
   if strcmp(goodMove, 'Yes')
       for idx = 1:numel(yTemp)
           y(pointIdx(idx)) = yTemp(idx);
       end
       
       set(l1,'Xdata', x(tempSection==1), 'YData',  y(tempSection==1))
       set(l2,'Xdata', x(tempSection==2), 'YData',  y(tempSection==2))
       set(l3,'Xdata', x(tempSection==3), 'YData',  y(tempSection==3))
   end
   
   delete(lTemp);      
   
   userHappy = questdlg('Are you done fixing the linear position?', 'Are you done?', 'No');
   
   if strcmp(userHappy, 'Cancel')
       lp = nan;
       sectIdx = nan;
       return;
   end
   lp = y;
   sectIdx = tempSection;
   sects{1} = y(tempSection==1);
   sects{2} = y(tempSection==2);
   sects{3} = y(tempSection==3);
end



end