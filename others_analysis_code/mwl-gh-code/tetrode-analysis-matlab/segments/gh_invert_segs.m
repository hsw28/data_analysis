function s = gh_invert_segs(in_s)

s = cellfun( @(x,y) [x(2), y(1)], ...
    in_s(1:(end-1)), in_s(2:end), 'UniformOutput',false);
% 
% % Add edge infinities typical case
% if (~isempty(in_s))
% 
%     veryLarge = 1000000000000;
% 
%     % Prepend -inf to start, if that region is empty in input
%     if ~(in_s{1}(1) < -veryLarge)
%         s = [[-inf,in_s{1}(1)];s];
%     end
% 
%     % Append end to inf, if that region is empty in input
%     if ~(in_s{end}(2) > veryLarge)
%         s = [s;[in_s{end}(2),inf]];
%     end
% 
% end
% 
% % Add edge infinities empty input case
% if(isempty(s) && isempty(in_s))
%     s = {[-inf,inf]};
% end