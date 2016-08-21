function names = get_dir_names(directory)
    
    d = dir(directory);
    names = cell(length(d),1);
    for i=1:length(d)
        names(i) = {d(i).name};
    
    end
end
