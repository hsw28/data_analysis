function exp = copy_epoch_tc(exp, e1, e2)

el = {e1 e2};

link_file = fullfile(exp.session_dir, ['cl_link_',e1,'_',e2,'.mat']);
if ~exist(link_file, 'file')
    disp(link_file)    
    error('copy_epoch_tc: cannot find the link file, check the epoch order.');
        
end

f = load(link_file);
link_data = f.link_data;

switch isfield(f, 'column_names')
    case 1
        col_names = f.column_names; %#ok
    otherwise
        warning('Obsolete linker file found. Column Names not found. Consider re-creating it!');%#ok
        col_names = {'Tetrode', e1, e2};%#ok
end

%% Get the Tetrode ID and cluster file ID for each cluster in the experiment
for e = el % for each epoch in the epoch list
    e  = e{1};%#ok
    ep.(e).tet = {exp.(e).clusters.tetrode}';
    ep.(e).tet = {exp.(e).clusters.tetrode}';

    ep.(e).cl  = {exp.(e).clusters.clfile};
    for i = 1:length(ep.(e).cl)
        c = ep.(e).cl{i};
        [a c] = fileparts(c);
        ep.(e).cl(i) = {c};
    end    
    ep.(e).cl = ep.(e).cl';
end
%{
disp('');
[d i] = sort(ep.(e1).tet);
disp(e1)
[ep.(e1).tet(i) ep.(e1).cl(i)]
disp(e2)
[d i] = sort(ep.(e2).tet);
[ep.(e2).tet(i) ep.(e2).cl(i)]
%}
%% Create the link between the two epochs

for i= 1:size(link_data,1) 
    
    tet = link_data{i,1};
    cl.(e1) = link_data{i,2};
    cl.(e2) = link_data{i,3};
    %disp(['Tet:',tet, '  ep1:', cl.(e1), '  ep2:', cl.(e2)]);
    
    ind_e1 = intersect(find(strcmp(ep.(e1).tet, tet)), find(strcmp(ep.(e1).cl, cl.(e1))));
	ind_e2 = intersect(find(strcmp(ep.(e2).tet, tet)), find(strcmp(ep.(e2).cl, cl.(e2))));
 
    if ~isempty(ind_e1) && ~isempty(ind_e2)
        exp.(e1).clusters(ind_e1).([e2,'_tc1']) = exp.(e2).clusters(ind_e2).tc1;
        exp.(e1).clusters(ind_e1).([e2,'_tc2']) = exp.(e2).clusters(ind_e2).tc2;

        exp.(e2).clusters(ind_e2).([e1,'_tc1']) = exp.(e1).clusters(ind_e1).tc1;
        exp.(e2).clusters(ind_e2).([e1,'_tc2']) = exp.(e1).clusters(ind_e1).tc2;

        e2_fsz = size(exp.(e2).clusters(ind_e2).tc1);
        e1_fsz = size(exp.(e1).clusters(ind_e1).tc1);      
    end
    
    
end
for i=1:length(exp.(e1).clusters)
    if isempty( exp.(e1).clusters(i).([e2,'_tc1']) )
        exp.(e1).clusters(i).([e2,'_tc1']) = ones(e2_fsz);
        exp.(e1).clusters(i).([e2,'_tc2']) = ones(e2_fsz);
    end
end
for i=1:length(exp.(e2).clusters)
    if isempty( exp.(e2).clusters(i).([e1,'_tc1']) )
        exp.(e2).clusters(i).([e1,'_tc1']) = ones(e1_fsz);
        exp.(e2).clusters(i).([e1,'_tc2']) = ones(e1_fsz);

    end
end

 








end