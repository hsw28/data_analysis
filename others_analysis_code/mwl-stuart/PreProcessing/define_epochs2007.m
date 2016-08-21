function [e_names, e_times] = define_epochs2007(tstart, tend)
    % A simple GUI used to create an epoch.def file
    % written by Stuart Layton 2009. Requires MWLIO
    % 
    % this version allows for compatability with matlab2007 and 2008. this
    % code will execute if running 2007

    e_names = {};
    e_times = [];
    
    dlg = {'Enter the epoch name', 'Start time in seconds', 'End time in seconds'};
    name = 'New Epoch Definition';
    def_resp ={'Name', num2str(tstart), num2str(tend)};
    
    go = 1;
    while go
        n_epochs = numel(e_names);
        ans = questdlg('Define more epochs?', [num2str(n_epochs), ' epochs defined'] );
        if strcmp(ans, 'Yes')
            n_epochs = n_epochs + 1;
            resp = inputdlg(dlg, name, 1, def_resp);
            e_names{n_epochs} = resp{1};
            ts = str2double(resp{2});an
            te = str2double(resp{3});
            e_times(n_epochs,:) = [ts, te];
        else
            go = false;
        end
    end
 end