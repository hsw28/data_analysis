function [laps] = exp_lapify(pos, varargin)


args.plot_laps = 0;

args = parseArgsLite(varargin,args);

min_p = min(pos.lp);
max_p = max(pos.lp);

%pos.lp = smoothn(pos.lp, 5);
dp = .25;

binned_lp = zeros(size(pos.lp));
binned_lp(pos.lp<= min_p + dp) = 1;
binned_lp(pos.lp>= max_p - dp) = 3;
binned_lp(isnan(pos.lp))=NaN;
binned_lp(binned_lp==0) = 2;

i = 2;
while isnan(binned_lp(1))
    binned_lp(1) =  binned_lp(i);
    i = i+1;
end
    
while any(isnan( binned_lp))
     binned_lp(find(isnan( binned_lp))) =  binned_lp(find(isnan( binned_lp))-1); %#ok
end


gp = gradient(binned_lp);


ind = [];
for i=1:numel(gp)-1
    if gp(i)~=gp(i+1) && gp(i)~=0
        ind(end+1) = i;
    end
end

out_laps = [];
ret_laps = [];

for i = 1:numel(ind)-1
    
    %disp([num2str(i), '  ', num2str(gp(ind(i))), ':', num2str(gp(ind(i+1)))]);
    if gp(ind(i))==gp(ind(i+1))
        
       
        if gp(ind(i))>0
            out_laps(end+1,1) = pos.ts(ind(i));
            out_laps(end,2) = pos.ts(ind(i+1));
        else
            ret_laps(end+1,1) = pos.ts(ind(i));
            ret_laps(end,2) = pos.ts(ind(i+1));
        end
    end
end



if args.plot_laps
    
    figure;
    plot(pos.ts, pos.lp, 'linewidth', 2);
    for i=1:size(out_laps,1)
        line(out_laps(i,:), [min_p max_p], 'color', 'k', 'linewidth', 4, 'linestyle', '--');
    end
    for i=1:size(ret_laps,1)
        line(ret_laps(i,:), [max_p min_p], 'color', 'r', 'linewidth', 4, 'linestyle', '--');
    end
end



out_laps(:,3) = 1;
ret_laps(:,3) = -1;

laps = [out_laps; ret_laps];