function [posIdx distMat] = fit_behavior_to_w_maze(xpos, ypos)
    
    %initialize the figure objects
    hFig = figure();
    hAx = axes('Position', [.055 .13 .939 .848]);
    behaviorPoints = [];
    mazeLines = [];
    mazePoints = [];
    breakLines = [];
    
    posIdx = [];
    distMat = [];
    
    %setup the callbacks
    oldFnMove   = get(hFig, 'WindowButtonMotionFcn');
    oldFnKey    = get(hFig, 'KeyPressFcn');
    oldFnDown   = get(hFig, 'WindowButtonDownFcn');
    oldFnUp     = get(hFig, 'WindowButtonUpFcn');
    
    set(hFig, 'WindowButtonMotionFcn', @mouseMoved);
    set(hFig, 'WindowButtonDownFcn', @mouseBtnDown);
    set(hFig, 'WindowButtonUpFcn', @mouseBtnUp);
    set(hFig, 'KeyPressFcn', @keyPressed);

    mouseBtnState = 0; % 0 no button down, 1 = button currently pressed
    ptColIdx = 0;
    
    %initialize the maze parameters
    xmed = nanmedian(xpos);
    ymed = nanmedian(ypos);
    width = max(xpos) - min(xpos);
    height = max(ypos) - min(ypos);
    [xmed ymed width height]
    
    % draw the maze
    [pts, lineOrder] = define_w_maze(xmed, ymed, width, height, 0);

    setupGraphicalObjects(xpos, ypos, pts, lineOrder, hAx);
    doneBtn = uicontrol('Style','PushButton', 'Parent', hFig, 'Units', 'normalized', 'Position', [.392 .026 .239 .047],...
        'String', 'Done!', 'Callback', @doFinish);

    % Create the graphical objects for plotting
    function setupGraphicalObjects(xpos, ypos, pts, lineOrder, hAx)
       
        behaviorPoints = line(xpos, ypos, 'linestyle', 'none', 'marker', '.', 'Parent', hAx);
        for i = 1:size(lineOrder,2)
            mazeLines(i) = line(1,1 , 'linewidth', 2, 'color', 'r', 'Parent', hAx);
        end
 
        for i = 1:size(pts,1)
            mazePoints(i) = line(1,1, 'marker', '.', 'markersize', 30, 'color', 'r', 'Parent', hAx);
        end
        breakLines(1) = line(1,1,'linestyle', '--', 'color', 'g', 'Parent', hAx, 'linewidth', 2);
        breakLines(2) = line(1,1,'linestyle', '--', 'color', 'g', 'Parent', hAx, 'linewidth', 2);
        updateGraphicalObjects();

    end

    %update the graphical objects following a mouse event that might have
    %moved the points
    
    function updateGraphicalObjects()
        for i = 1:size(lineOrder,2)
            set(mazeLines(i), 'XData', pts(lineOrder(:,i),1), 'YData',  pts(lineOrder(:,i),2) );
        end
        
        set(mazePoints, 'MarkerSize', 30, 'Color', 'r');
         
         for i = 1:size(pts,1)
            set(mazePoints(i), 'XData', pts(i,1), 'YData', pts(i,2) );
            if i == ptColIdx
                set(mazePoints(i), 'Color', 'y', 'MarkerSize', 40);
            end
         end  
         
         set(breakLines(1), 'XData', [mean(pts([1,6],1)) mean(pts([2,5],1)) ], 'YData', [mean(pts([1,6],2)) mean(pts([2,5],2))] );
         set(breakLines(2), 'XData', [mean(pts([6,4],1)) mean(pts([5,3],1)) ], 'YData', [mean(pts([6,4],2)) mean(pts([5,3],2))] );

    end

        
    

    function mouseMoved(src, event)
%         if mouseBtnState == 0
%             disp('mouseMoved()');
%         elseif mouseBtnState == 1
%             disp('mouseDragged()');
%         end
        
        cp = getMouseLocation();
     
        
        if mouseBtnState == 1 && ptColIdx ~= 0
            pointMoved(ptColIdx, cp);            
            updateGraphicalObjects();
        end
    end

    function mouseBtnDown(src, event)
%         disp('mouseBtnDown()');
        mouseBtnState = 1;
        cp = getMouseLocation();
        ptColIdx = checkForCollisions(cp, pts);
        updateGraphicalObjects();
    end

    function mouseBtnUp(src, event)
%         disp('mouseBtnUp()');
        
        mouseBtnState = 0;
        ptColIdx = 0;
        updateGraphicalObjects();
    end

    function keyPressed(src, event)
%         disp('keyPressed()');
    end

    function loc =  getMouseLocation()
        loc = get(hAx, 'CurrentPoint');
        loc = loc(1,1:2)';
    end

    function colIdx = checkForCollisions(cp, pts)
        maxDist = 10;
       
        xCol = abs(pts(:,1) - cp(1)) < maxDist;
        yCol = abs(pts(:,2) - cp(2)) < maxDist;
        
        colIdx = find(xCol & yCol, 1, 'first');
        
        if isempty(colIdx)
            colIdx = 0;
        end
        
        fprintf('Collision at point: %d\n', colIdx);
    end

    function pointMoved(pointIdx, pos)
      
         
        switch pointIdx
            case 1
                pts(1,:) = pos;
                pts(2,1) = pos(1);
                pts(4,2) = pos(2);
            case 2
                pts(1,1) = pos(1);
                pts(2,:) = pos;
                pts(3,2) = pos(2);
            case 3
                pts(2,2) = pos(2);
                pts(3,:) = pos;
                pts(4,1) = pos(1);
            case 4 
                pts(1,2) = pos(2);
                pts(3,1) = pos(1);
                pts(4,:) = pos;
            case 5
                pts(2,2) = pos(2);
                pts(3,2) = pos(2);
                pts(5,:) = pos;
                pts(6,1) = pos(1);
            case 6
                pts(1,2) = pos(2);
                pts(4,2) = pos(2);
                pts(5,1) = pos(1);
                pts(6,:) = pos;
        end
        %pts( [5,6], 1) = mean( [pts(1,1), pts(4,1)] );
        pts(5,2) = pts(2,2);
        pts(6,2) = pts(1,2);
        
    end
    
    function doFinish(src, event)
        xPts = [];
        yPts = [];
        
        nBin = 25;
        for i = 1:size(lineOrder,2)
            
            p1 = round( pts(lineOrder(1,i),1:2) );
            p2 = round( pts(lineOrder(2,i),1:2) );
        
            if p1(1) == p2(1) %line is verticle
                disp('Line in verticle');
                y = linspace(p1(2), p2(2), nBin);
                x = repmat(p1(1), size(y));
            elseif p1(2) == p2(2)
                x = linspace(p1(1), p2(1), nBin);
                y = repmat(p1(2), size(x));
            end
            xPts = [xPts; x(:)];
            yPts = [yPts; y(:)];
                
            %x = pts(lineOrder(1,i),1):dSeg:pts(lineOrder(2,i),1)
            %y = pts(lineOrder(1,i),2):dSeg:pts(lineOrder(2,i),2);
%             line(x,y, 'marker','.', 'markersize', 20, 'color', 'b');
 %           mazeLines(i) = line(1,1 , 'linewidth', 2, 'color', 'r', 'Parent', hAx);
        end        
        [~,index] = unique([xPts(:), yPts(:)],'rows', 'first');        % Capture the index of the unique items
        xPts = xPts(sort(index));                          % Index y with the sorted index;
        yPts = yPts(sort(index));
            
        tri = DelaunayTri(xPts, yPts);
        test = [repmat(50, 50, 1), linspace(160, 155, 50)'];
        posIdx = tri.nearestNeighbor(xpos, ypos);
          
        unqPos = 1:max(posIdx);
        distMat = zeros(numel(unqPos));
        for i = 1 : numel(unqPos)
            distMat(i,i) = 0;
            for j = i+1 : numel(unqPos)
               d = distanceBetweenPoints(unqPos(i), unqPos(j), xPts, yPts);
               distMat(i,j) = d;
               distMat(j,i) = d;
           end
        end
       
        set(hFig, 'UserData', 'Done');
    end

    function dist = distanceBetweenPoints(idx1, idx2, xPts, yPts)
        yHoriz = pts(2,2);
        xDist = abs(xPts(idx1) - xPts(idx2));
        if xDist > 0
            yDist = abs(yPts(idx1) - yHoriz) + abs(xPts(idx1) - xPts(idx2)) + abs(yPts(idx2) - yHoriz) ;
        else 
            yDist = abs(yPts(idx1) - yPts(idx2));
        end
        dist = xDist + yDist;
    end

    waitfor(hFig, 'UserData');
    close(hFig);
end

