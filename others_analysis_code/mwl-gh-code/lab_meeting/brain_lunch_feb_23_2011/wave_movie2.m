function f = wave_movie2(rat_conv_table, varargin)
% [f, movie_opt] = wave_movie2(rat_conv_table, varargin)   Make a wave data movie
% wave and reconstruction data
% Returns F the figure handle, movie_opt, all non-empty param values
% including those that user passes and those that get computed by wave_movie2
%
% Params 'eeg_r', 'mua_pr', 'mua_ir', 'multi_r_pos', 'pos_info' are
% the data to be plotted in movie form.
% Params 'eeg_r_subplot', 'mua_pr_subplot', 'mua_ir_subplot',
%  'multi_r_pos_subplot', and 'pos_subplot' are [n_row, n_col, id]
%   triplets specifying plotting position of various datas
%   make 'multi_r_pos_subplot' the same as 'pos_subplot' in order
%   to plot reconstructed position on the 2-d track picture
%
% 'framerate' specifies framerate,  default will be samplerate of 
%  the first non-empty data
% 'speedup' is the time compression factor.  0.1 makes a 10x slow-mo movie
% 


p = inputParser();
p.addParamValue('eeg_r',[]);
p.addParamValue('eeg_r_subplot',[]);
p.addParamValue('mua_pr',[]);
p.addParamValue('mua_pr_subplot',[]);
p.addParamValue('mua_ir',[]);
p.addParamValue('mua_ir_subplot',[]);
p.addParamValue('multi_r_pos',[]);
p.addParamValue('multi_r_pos_subplot',[]);
p.addParamValue('pos_info',[]);
p.addParamValue('pos_subplot',[]);
p.addParamValue('track_info',[]);

p.addParamValue('wave_frame_opt1',[]);
p.addParamValue('wave_frame_opt2',[]);
p.addParamValue('wave_frame_opt3',[]);

p.addParamValue('framerate');
p.addParamValue('speedup');

p.addParamValue('avi_name',[]);