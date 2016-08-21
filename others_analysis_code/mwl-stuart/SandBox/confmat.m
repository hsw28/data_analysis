function [c order] = confmat(v, v_hat)

v = round(v*10)/10;
v_hat = round(v_hat*10)/10;

if ~all(size(v)==size(v_hat))
    error('Input vectors should be the same size');
end 
if ~isvector(v) || ~isvector(v_hat)
    error('Inputs should be vectors');
end



classlist = unique(v);


c = zeros(numel(classlist), numel(classlist));

for i=1:numel(v)
    idx1 = find(classlist == v(i));
    idx2 = find(classlist == v_hat(i));
    
    if isempty(idx2)
       % disp('V2 fail');
        continue;
    end
    c(idx1, idx2) = c(idx1, idx2) + 1;    
end

for i = 1:size(c,1)
    c(:,i) = c(:,i) / sum(c(:,i));
end
order = classlist;