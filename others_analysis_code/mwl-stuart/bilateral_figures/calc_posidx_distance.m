function [d, dFull] = calc_posidx_distance(pos1, pos2, pfE)

p1{1} = removeStart(pos1, pfE(1,1), pfE(1,2) );
p1{2} = removeMiddle(pos1, pfE(2,1), pfE(2,2));
p1{3} = removeEnd(pos1, pfE(3,1), pfE(3,2));

p2{1} = removeStart(pos2, pfE(1,1), pfE(1,2));
p2{2} = removeMiddle(pos2, pfE(2,1), pfE(2,2));
p2{3} = removeEnd(pos2, pfE(3,1), pfE(3,2));
d = [];
for i = 1:3
    for j = 1:3
        d( 3*(i-1) + j , : ) = abs( p1{i} - p2{j} );
    end
end
dFull = d;
d = nanmin(d);
    
%     idxStart1 = pos1 <= pfEdges(1,2);
%     idxStart2 = pos2 <= pfEdges(1,2);
% 
%     idxMiddle1 = pos1 >= pfEdges(2,1) & pos1 <= pfEdges(2,2);
%     idxMiddle2 = pos2 >= pfEdges(2,1) & pos2 <= pfEdges(2,2);
%     
%     idxEnd1 = pos1 >= pfEdges(3,1);
%     idxEnd2 = pos2 >= pfEdges(3,1);
% 
%     fprintf('Input: %d %d\n', pos1, pos2);
%     d = [];
% for traj = 1:size(pfEdges,1)        
%         
%    fprintf('Using Edges %02d : %d ', pfEdges(traj,:))
% 
%     p1 = pos1;
%     p2 = pos2;
%         
%     switch traj
% 
% 
%         case 1
%             d(traj,:) = abs(p1 - p2);
% 
% 
%         case 2
% 
%             cf = pfEdges(2,1) - pfEdges(3,1); % Correction factor
%             p1(idxEnd1) = p1(idxEnd1) +  cf;
%             p2(idxEnd2) = p1(idxEnd2) +  cf;
% 
%             p1(idxMiddle1) = nan;
%             p2(idxMiddle2) = nan;
% 
%             d(traj,:) = abs(p1 - p2);
% 
%         case 3
%             p1 = pos1;
%             p2 = pos2;
% 
%             cf = mean(pfEdges(2,:));
%             t1 = p1(idxMiddle1);
%             t2 = p2(idxMiddle2);
% 
%             t1 = (-1 * (t1 - cf)) + cf;
%             t2 = (-1 * (t2 - cf)) + cf;
% 
%             p1(idxMiddle1) = t1;
%             p2(idxMiddle2) = t2;
% 
%             p1(idxStart1) = nan;
%             p2(idxStart2) = nan;
% 
%             d(traj,:) = abs(p1 - p2);
% 
% 
%     end
%     fprintf('  In: (%d, %d)\tDist: %d\n', p1, p2, d(traj));
% 
% end
% 
% fprintf('%d ', d);
% fprintf('\n');
% d = nanmin([d]);


end

function p = removeStart(p, min, max)

    remIdx = p>=min  & p<=max;
    p(remIdx) = nan;

end

function p = removeMiddle(p, min, max)

    remIdx = p>=min & p <= max;
    shiftIdx = p>max;
    shiftAmt = min - max;

    p(remIdx) = nan;
    p(shiftIdx) = p(shiftIdx) + shiftAmt;

end
function p = removeEnd(p, min, max)
    remIdx = p<min;
    
    flipIdx = p>=min & p<=min;
    cf = mean([min max]);
    
    p(remIdx) = nan;
    p(flipIdx) = (-1 * (p(flipIdx) - cf)) + cf;

end








