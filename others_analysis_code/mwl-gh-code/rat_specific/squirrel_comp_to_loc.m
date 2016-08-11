function names = squirrel_comp_to_loc(input_names)

comp_names = {'G1','H2','I1','I2','H1','F1','F2','E1','D2','D1','E2','G2','Ref3','Ref2','A2','A1','B2','C1','C2','B1','Ref1'};
loc_names = {'L1','L2','L3','L4','L5','L6','L7','L8','L9','L10','L11','R1','R2','R3','R4','R5','R6','R7','R8','R9','R10'};

if(not(iscell(input_names)))
    in_name = input_names;
    input_names = cell(1);
    input_names{1} = in_name;
end

for i = 1:numel(input_names)
    a = strcmp(input_names{i},comp_names);
    names{i} = loc_names{a};
end