function [linvel] = pos_to_velocity_w(lp, varargin)

args.kernelSizeMs= 100;
args.velThold = 10;

c2l = lp.paths.c2l;
c2r = lp.paths.c2r;
l2r = lp.paths.l2r;

c2l = smoothn(c2l, args.kernelSizeMs, 1000/lp.samplerate);
c2r = smoothn(c2r, args.kernelSizeMs, 1000/lp.samplerate);
l2r = smoothn(l2r, args.kernelSizeMs, 1000/lp.samplerate);

vel_c2l = smoothn(gradient(c2l, .01), args.kernelSizeMs, 1000/lp.samplerate);
vel_c2r = smoothn(gradient(c2r, .01), args.kernelSizeMs, 1000/lp.samplerate);
vel_l2r = smoothn(gradient(l2r, .01), args.kernelSizeMs, 1000/lp.samplerate);

linvel = max([vel_c2l'; vel_c2r'; vel_l2r'])';



end

