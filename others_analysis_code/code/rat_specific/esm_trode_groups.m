function trode_groups = jk_trode_groups()

group1_trodes = {'g1','h2','i1','g2','e1','i2'};
group2_trodes = {'a2','d2','h1','a1','d1','f1'};
group3_trodes = {'b2','e2','f2','c1','c2','b1'};

trode_groups{1}.trodes = group1_trodes;
trode_groups{2}.trodes = group2_trodes;
trode_groups{3}.trodes = group3_trodes;

trode_groups{1}.color = [1 0 0];
trode_groups{1}.color = [0 1 0];
trode_groups{1}.color = [0 0 1];