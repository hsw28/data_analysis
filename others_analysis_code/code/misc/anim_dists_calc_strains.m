function strains_mat = anim_dists_calc_strains(pos,pref_mat)

n_points = numel(pos);
strains_mat = zeros(n_points,n_points);

for n = 1:n_points
    this_diff = transpose(pos(n) - pos);
    %this_diff
    %pref_mat(n,:)
    strain_mag = abs(this_diff) - pref_mat(:,n);
    strains_mat(:,n) = -strain_mag .* this_diff;
    %disp('pos')
    %pos
    %disp('n and sum');
    %[n, sum(strains_mat(:,n),1)]
    %disp('this_diff, strain_mag, and strains_mat(:,n)');
    %[this_diff, strain_mag,strains_mat(:,n)]
end
