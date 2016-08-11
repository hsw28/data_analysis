function trode_groups = jk_trode_groups()

group1_trodes = {'g2','f1','a2','g1','f2','d2'};
group2_trodes = {'a1','b2','d1','e1','i1','e2'};
group3_trodes = {'h2','c1','c2','i2','h1','b1'};

trode_groups{1}.trodes = group1_trodes;
trode_groups{2}.trodes = group2_trodes;
trode_groups{3}.trodes = group3_trodes;

trode_groups{1}.color = [1 0 0];
trode_groups{1}.color = [0 1 0];
trode_groups{1}.color = [0 0 1];