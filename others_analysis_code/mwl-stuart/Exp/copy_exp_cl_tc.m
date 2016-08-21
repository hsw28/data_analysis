function cl = copy_exp_cl_tc(cl1, cl2)
% copys the tuning curves from cl1 to cl2. 

if numel(cl1)~=numel(cl2)
    error('Must have same number of clusters to copy tuning curves');
end

for i=1:numel(cl1)
    cl2(i).tc1 = cl1(i).tc1;
    cl2(i).tc2 = cl1(i).tc2;
    cl2(i).tc_bw = cl1(i).tc_bw;
end
cl = cl2;