clear all; close all;
for i =  1:2
    switch i
        case 1
            clear;
            [MU, HPC] = load_HPC_RSC_data;
            p = [];
            state = 'sleep';
        case 2
            clear
            [MU, HPC, p] = load_HPC_RSC_run_data;
            state = 'run';
    end
    
    f = calc_mu_xcorr(MU);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/01-mu_xcorr_%s.svg', state), f)
    
    f = calc_inter_ripple_interval(HPC);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/02-inter_ripple_interval_%s.svg', state), f);
    
    f = calc_rip_trig_mu(MU, HPC, 'hpc', p);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/03-ripple_trig_hpc_mu_rate_%s.svg', state), f);

    f = calc_rip_trig_mu(MU, HPC, 'ctx', p);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/04-ripple_trig_ctx_mu_rate_%s.svg', state), f);

%     f = calc_frame_trig_mu(MU, 'hpc', p);
%     plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/05-frame_trip_hpc_mu_rate_%s', state), f);
%     
%     f = calc_frame_trig_mu(MU, 'ctx', p);
%     plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/06-frame_trip_ctx_mu_rate_%s', state), f);

    f = calc_rip_trig_mu_2(MU, HPC, 'hpc', p);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/07-fast_vs_slow_ripple_trig_hpc_mu_rate_%s.svg', state), f);
      
    f = calc_rip_trig_mu_2(MU, HPC, 'ctx', p);
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/08-fast_vs_slow_ripple_trig_ctx_mu_rate_%s.svg', state), f);
    
    f = calc_mu_xcorr_frames(MU, 'wrap');
    plot2svg( sprintf('/data/HPC_RSC/RunVsSleep/09-mu_frame_xcorr_%s.svg',state), f);

end
%%

%%
calc_frame_trig_mu;
%%
calc_frame_trig_frame;
%%
calc_frame_d_start_dist;
%%
calc_frame_trig_mu_rate_corr;