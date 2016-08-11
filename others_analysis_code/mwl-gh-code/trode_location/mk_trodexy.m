function trode_xy = mk_trodexy(dat,conv_table)




%is dat a cdat or an sdat?
if(isfield(dat,'data'))   % It's a cdat.  Use chanlabels field
    %its_cdat = true;
    %cdat = dat;
    %nchans = size(cdat.data,2);
    trode_names = dat.chanlabels;
elseif(isfield(dat,'clust'))  % It's an sdat.  Make trode names from clusts
    %its_cdat = false; % it's an sdat
    %sdat = dat;
    %nchans = numel(sdat.clust);
    trode_names = cellfun(@(x) x.comp, dat.clust,'UniformOutput',false);
elseif(iscell(dat))   
    trode_names = dat;
elseif(isempty(dat))
    trode_names = conv_table.data( find( strcmp('comp',conv_table.label), 1, 'first'), :);
else
    error('Input 1 to trodexy seems to be neither cdat nor sdat nor trode_name list nor empty.');
end

name_row = find(strcmp(conv_table.label, 'comp'), 1, 'first');
ml_row   = find(strcmp(conv_table.label, 'brain_ml'),   1, 'first');
ap_row   = find(strcmp(conv_table.label, 'brain_ap'),   1, 'first');

trode_xs = cellfun(@(x) ...
    conv_table.data{ ml_row, strcmp(x,conv_table.data(name_row,:)) }, ...
    trode_names);

trode_ys = cellfun(@(x) ...
    conv_table.data{ ap_row, strcmp(x,conv_table.data(name_row,:)) }, ...
    trode_names);

trode_xy = [trode_xs', trode_ys'];

%nchans = size(cdat.data,2);

%trodexy = NaN.*zeros(nchans,2);

% comp_ind = find(strcmp(conv_table.label,'comp'));
% x_ind = find(strcmp(conv_table.label,'brain_ml'));
% y_ind = find(strcmp(conv_table.label,'brain_ap'));
% 
%  
% 
% for i = 1:nchans
%     if(its_cdat)
%         this_comp = find(strcmp(conv_table.data(comp_ind,:),cdat.chanlabels{i}));
%     else
%         this_comp = find(strcmp(conv_table.data(comp_ind,:),sdat.clust{i}.comp));
%     end
%     for j = [1,2]
%         if(j == 1)
%             this_row_ind = x_ind;
%         elseif (j == 2)
%             this_row_ind = y_ind;
%         end
%         %this_row_ind
%         %this_comp
%         trodexy(i,j) = conv_table.data{this_row_ind,this_comp};
%     end
% end