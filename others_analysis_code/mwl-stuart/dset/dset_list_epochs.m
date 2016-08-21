function epList = dset_list_epochs(epoch_type)
% DSET_LIST_EPOCHS - provides a cell matrix of all the animals, days, and epochs that are analyzable given a specific epoch_type (run / sleep)

epList = {};
epoch_type = lower(epoch_type);
if nargin<1
    error('Epoch Type must be specified, valid choices are: run, sleep');
end
if ~ischar(epoch_type)
    error('Epoch type must be a string');
end  

if strcmp(epoch_type, 'run')
    eps = [2,4];
elseif strcmp(epoch_type, 'sleep')
    eps = [3, 5];
else
    error('Invalid epoch type specified, valid choices are: run, sleep');
end

% idx = 1;
% for ep = eps
% 
%     for i = [3:7, 9,10]
%         
%         if i == 4 && ep == 5
%             continue;
%         end
%               
%         epList{idx,1} = 'Bon';
%         epList{idx,2} = i;
%         epList{idx,3} = ep;
%         idx = idx+1;
%         
%     end
    
%     for i = [5]
%         if ep == 3
%             continue;
%         end
%         epList{idx,1} = 'Fra';
%         epList{idx,2} = i;
%         epList{idx,3} = ep;
%         idx = idx+1; 
%     end
  
%     if ep == 3
%         for i = [11, 12, 15]
%             epList{idx,1} = 'spl11';
%             epList{idx,2} = ['day', num2str(i)];
%             epList{idx,3} = 'sleep';
%             idx = idx+1;
%         end
%     end
%     
% end

if strcmp('sleep', epoch_type)

    epList(end+1, :) = {'Bon', 4, 3};
    epList(end+1, :) = {'Bon', 5, 3};
    epList(end+1, :) = {'Bon', 6, 3};
    epList(end+1, :) = {'Bon', 9, 3};
    epList(end+1, :) = {'Bon', 4, 5};
    epList(end+1, :) = {'Bon', 5, 5};
    epList(end+1, :) = {'Bon', 6, 5};
    epList(end+1, :) = {'Bon', 9, 5};
    
    epList(end+1, :) = {'spl11', 'day11', 'sleep'};
    epList(end+1, :) = {'spl11', 'day12', 'sleep'};

end


if strcmp('run', epoch_type)
    epList(end+1, :) = {'Bon', 4, 2};
    epList(end+1, :) = {'Bon', 5, 2};
    epList(end+1, :) = {'Bon', 6, 2};
    epList(end+1, :) = {'Bon', 9, 2};
    epList(end+1, :) = {'Bon', 4, 4};
    epList(end+1, :) = {'Bon', 5, 4};
    epList(end+1, :) = {'Bon', 6, 4};
    epList(end+1, :) = {'Bon', 9, 4};
    
    epList(end+1, :) = {'spl11', 'day11', 'run'};
    epList(end+1, :) = {'spl11', 'day12', 'run'};

    %     epList(end+1, :) = {'spl11', 'day13', 'run'};
%     epList(end+1, :) = {'spl11', 'day14', 'run'};
end

