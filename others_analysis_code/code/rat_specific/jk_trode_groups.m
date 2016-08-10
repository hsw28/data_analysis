function trode_groups = jk_trode_groups()

group1_trodes = {'a1','a2','f1','f2'};
group2_trodes = {'b1','b2','g1','g2','e1','e2'};
group3_trodes = {'c1','c2','d1','d2'};

trode_groups{1}.trodes = group1_trodes;
trode_groups{2}.trodes = group2_trodes;
trode_groups{3}.trodes = group3_trodes;

trode_groups{1}.color = [1 0 0];
trode_groups{1}.color = [0 1 0];
trode_groups{1}.color = [0 0 1];