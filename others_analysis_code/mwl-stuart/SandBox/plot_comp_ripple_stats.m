function p_dat = plot_comp_ripple_stats(data)
epochs = fieldnames(data);
field_names = [];
for i = 1:length(epochs)
    e = epochs{i};
    field_names = fieldnames(data.(e));
end;

for i = 1:length(field_names)
    figure;
    f = field_names{i};
    title(f);
    minimum.(f) = 1000000;
    maximum.(f) = -100000;
    for ep = epochs  %% Comput the limits of the histogram (min, max)
        e = ep{:};
        minimum.(f) = min([data.(e).(f)(:); minimum.(f)]);
        maximum.(f) = max([data.(e).(f)(:); maximum.(f)]);        
    end
    
    c = 'rk';
    epochs
    for j = 1:length(epochs)
        e = epochs{j};
        
        bins = linspace(minimum.(f), maximum.(f), 20);
        h.(e) = histc(data.(e).(f),bins);
        hold on;
        plot(bins, h.(e)./ numel(data.(e).(f)), c(j)); 
    end
    legend(epochs);
    
end