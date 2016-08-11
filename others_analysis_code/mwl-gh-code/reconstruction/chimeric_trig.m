function r_pos_chimera = chimeric_trig(r_pos_array,phase_list,pos_info,trig_opt)

n_r_pos = numel(r_pos_array);
r_pos_chimera = [];

for n = 1:n_r_pos
    this_trig = gh_triggered_reconstruction(r_pos_array,pos_info,trig_opt{:},'phase',phase_list(n));
    if(isempty(r_pos_chimera))
        r_pos_chimera = this_trig;
    else
        r_pos_chimera(n) = this_trig(n);
    end
end