s = 100000;
r = 100;
a = rand(5,s); b = rand(5,r); 

t = [];
n = 10;
disp(['Data Points: ', num2str(s), ' iterations: ', num2str(n)]); 
for i=1:n
    tic; 
    d = distance(a,b); 
    t(i) = toc; 
end

disp(['Average run time: ', num2str(mean(t))]);
t = [];
for i=1:n
    tic; 
    d = sqrt(bsxfun(@plus,dot(a,a,1)',dot(b,b,1))-2*a'*b); 
    t(i) = toc;
end
disp(['Average run time: ', num2str(mean(t))]);
