function new_sdat = assign_trode_info(sdat,rat_conv_table)

ncell = numel(sdat.clust);

for i = 1:ncell
    if(isempty(sdat.clust{i}.comp))
        disp(['Need a comp name for cluster ',sdat.clust{i}.name]);
        user_entry = input('Please enter it in single quotes (0, no quotes, for skip): ');
        if(isstr(user_entry))
            sdat.clust{i}.comp = user_entry;
        else
            break
        end
    end
    this_ap_loc = trode_conv(sdat.clust{i}.comp,'comp','brain_ap',rat_conv_table);
    this_ml_loc = trode_conv(sdat.clust{i}.comp,'comp','brain_ml',rat_conv_table);
    sdat.clust{i}.aploc = this_ap_loc;
    sdat.clust{i}.mlloc = this_ml_loc;
end

new_sdat = sdat;