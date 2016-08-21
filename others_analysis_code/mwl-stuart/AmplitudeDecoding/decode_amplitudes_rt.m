ex = exp14;
ep = 'amprun';
%%
amps_rt = load_exp_amplitudes(exp14,ep);
amps_rt = select_amps_by_feature(amps_rt, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
amps_rt = select_amps_by_feature(amps_rt, 'feature', 'amplitude', 'range', [150 Inf]);

%%

if isfield('position', ex.(ep))
    pos = ex.(ep).position.lin_pos;
    vel = ex.(ep).position.lin_vel;
    pts = ex.(ep).position.timestamp;
else
    pos = ex.(ep).pos.lp;
    vel = ex.(ep).pos.lv;
    pts = ex.(ep).pos.ts;
end

i = 1;
while isnan(pos(1))
    pos(1) = pos(i);
    i = i+1;
end
  
while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end
%a_bkp = load_tetrode_amps(ex,ep, 'threshold', 80);%
%cl_bkp = convert_cl_to_kde_format(ex15,'run_clustxy');



%% Decode using both Amplitudes and Clustered Data
ts = ex.(ep).et(1);
te = ex.(ep).et(2);

%te = 3950;
dt = .25;

%te = ;

ct = ts+20;
est_count = 0;
est = [];
total_dt = te-ts;
accum_dt = 0;
wb = my_waitbar(0);
    
disp('Starting the Decoding');
disp_now();
tbins = [];
err = [];
pbins = min(pos):.1:max(pos);
while ct+dt<te-dt
    t1 = max([ts, ct-200]);
    t_range = [t1, ct];
    d_range = [ct, ct+dt];
    
    est_count = est_count+1;
    
    warning off;
    e = decode_amplitudes(amps_rt, pos', t_range, d_range, 'dt', dt);  
    warning on;
    
    est(:,est_count) = e;
    
    accum_dt = accum_dt + dt;
    wb = my_waitbar(accum_dt/total_dt, wb);
    
    tbins(end+1) = ct;
    
    ct = ct+dt;
end
disp_now();
disp('Finished Decoding');
close(wb);
out.est = est;
out.pbins = pbins;
out.tbins = tbins;
%% 
figure;
imagesc(tbins, pbins, est); hold on;
plot(ex.amprun.pos.ts, ex.amprun.pos.lp, 'w');
set(gca,'Color','k');






