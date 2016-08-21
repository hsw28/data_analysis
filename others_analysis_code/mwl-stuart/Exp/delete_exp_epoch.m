function delete_exp_epoch(edir, ep)
[en et]  = load_epochs(edir);

if ~ismember(ep,en)
    error('Desired epoch does not exist');
end
    
resp = questdlg('Are you sure, this cannot be undone', ['WARNING - Deleting Epoch:', ep]);
if ~strcmp(resp,'Yes')
    return;
end


ind = ismember(en,ep);

en = en(~ind);
et = et(~ind,:);

save_epochs(edir,en,et);

 tt = dir(fullfile(edir,'t*'));
 tt_n = {tt.name};
 ind = logical(cell2mat({tt.isdir}));
 tt = tt_n(ind);
 for i=1:numel(tt)
     t = tt{i};
     cmd = ['rm -rf ', fullfile(edir, t , ep)];
     disp(['Removing: ',fullfile(edir,t,ep)]);
     system(cmd);
end