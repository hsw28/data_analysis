function [est_pos] =  pos_pdf_to_pos_estimate(est, tbins, pbins, pos, varargin)
args.decode_range = [nan nan];
args.n_spike = {};
args.dt = .25;
args.dp = .1;
args.smooth = 0;

args = parseArgsLite(varargin,args);


warning off;
interp_pos = interp1(pos.ts, pos.lp, tbins);
warning on;
sm_est = {};

if ~iscell(est)
    est = {est};
end

for i=1:numel(est); 
    sm_est{i} = est{i};
    if args.smooth
        disp('Smoothing');
        sm_est{i} = smoothn(est{i},3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    end
    
    [~, max_ind] = max(sm_est{i}); 
    est_pos{i} = pbins(max_ind);
        
end