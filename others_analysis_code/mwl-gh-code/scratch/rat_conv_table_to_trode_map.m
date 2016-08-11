function tMap = rat_conv_table_to_trode_map( rat_name, rat_conv_table, varargin )

p = inputParser();
p.addParamValue('initialSearchDate','010106');
p.addParamValue('endSearchDate','010115');
p.addParamValue('statusEveryNth',100);
p.addParamValue('trode_groups',[]);
p.parse(varargin{:});
opt = p.Results;

t = rat_conv_table;

tMap.ratName = rat_name;

n_trodes = size(rat_conv_table.data,2);
name_row = strcmp('comp',     t.label);
ap_row =   strcmp('brain_ap', t.label);
ml_row =   strcmp('brain_ml', t.label);

tMap.trodes = cell( 1, size(rat_conv_table.data,2) );

for n = 1:n_trodes

    this_trode.trodeName = t.data{name_row, n};
    this_trode.ap        = t.data{ap_row,   n};
    this_trode.ml        = t.data{ml_row,   n};

    this_trode.depth = cell(0);

    dayCounter = 0;

    if(~isempty(opt.trode_groups))

        current_date = opt.initialSearchDate;
        current_brain_area = 'initial';
        new_current_brain_area = 'initial';

        while( ~strcmp(current_date, opt.endSearchDate) );

            dayCounter = dayCounter + 1;
            if (mod(dayCounter,opt.statusEveryNth) == 0)
                current_date
            end

            today_trode_groups = opt.trode_groups('date',current_date,'silent',true);

            if iscell(today_trode_groups)

                trode_group_b = cellfun(@(x) any(strcmp(this_trode.trodeName, x.trodes)), today_trode_groups);

                if(any(trode_group_b))
                    new_current_brain_area = today_trode_groups{trode_group_b}.name;
                end
                
                if( ~strcmp(current_brain_area, new_current_brain_area) )
                    disp('New brain area');
                    new_ind = numel(this_trode.depth) + 1;
                    this_trode.depth{ new_ind }.date = current_date;
                    this_trode.depth{ new_ind }.brain_area = new_current_brain_area;
                    current_brain_area = new_current_brain_area;
                end

            end

            current_date = nextDate(current_date);

        end
    end

    tMap.trodes{n} = this_trode;

end


end

