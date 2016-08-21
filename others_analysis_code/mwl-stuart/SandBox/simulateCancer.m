

function simulateCancer(plateSize, pDivide)

plate = zeros(plateSize, plateSize);
nCells = 1;
cellLocations = zeros(plateSize*plateSize,2);

initX = randi(plateSize);
initY = randi(plateSize);

cellLocations(nCells,:) = [initX, initY];

plate(initX, initY) = 1;

f = figure;
a = axes();
im = imagesc(plate, 'Parent', a);


while(nCells < plateSize * plateSize)
    for i = 1:nCells
        divide = rand();
        if divide <= pDivide
            divideLocation = cellLocations(i,:);
            divideDir = randi(4);
            [x, y, v] = findNewLocation(divideLocation(1), divideLocation(2), plate, divideDir);
            if (v==1)
                nCells = nCells+1;
                plate(x,y) = 1;
                cellLocations(nCells,:) = [x,y];
            end
        end
    end
    set(im,'CData', plate);
    pause(.1);
end

end

function [x,y, valid] = findNewLocation(xin, yin, plate, direction)   
    x = xin;
    y = yin;
    valid = 1;
    % keep looking for new spot if current spot is occupied
    while( plate(x, y) == 1)
       switch direction
            case 1 % divide up
                y = y-1;
            case 2 % divide down
                y = y+1;
            case 3 % divide left
                x = x-1;
            case 4 % divide down
                x = x+1;
            otherwise
            warning('Invalid direction')
            x = xin;
            y = yin;
        return;
       end
       
       %if there has been a collision with a wall then just quit
       if y==0 || y==size(plate,2)+1 || x==0 || x==size(plate,1)+1 % hit the top
           x = xin; %return original values to say no division happend
           y = yin;
           valid = 0;
           return;
       end
       
    end
    

end