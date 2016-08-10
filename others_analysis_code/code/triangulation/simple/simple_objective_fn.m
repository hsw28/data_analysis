function score = simple_objective_fn(strains_mat)

score = sum(sum(strains_mat));