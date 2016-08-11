function data_on_blue_video(varargin)

p = inputParser();
p.addParamValue('eeg',[]);
p.addParamValue('m_reader',[]);
p.addParamValue('inputVideo','~/Desktop/blue_movie/movie3.avi');
p.addParamValue('outputVideo','~/Desktop/blue_movie/final_video.avi');
p.addParamValue('oneVideoTime',178.6);
p.addParamValue('oneRigTime', 60*12 + 162.4);
p.addParamValue('x_lim',[-0.1,6]);
p.addParamValue('y_lim',[-5, 0.3]);
p.addParamValue('timebase',2);
p.parse(varargin{:});
opt = p.Results;

if(isempty(opt.m_reader))
    m = VideoReader( opt.inputVideo );
else
    m = opt.m_reader;
end

opt.frameRate = get(m,'FrameRate');

v_opt_names = {'FrameRate'};
v_opts = reshape( ...
    [v_opt_names', cellfun(@(x) get(m,x), v_opt_names', 'UniformOutput',false)]', ...
    1, []);

m_out = VideoWriter( opt.outputVideo);
set(m_out, v_opts{:});
open(m_out);

%for n = 500:(get(m, 'NumberOfFrames'))
for n = 1:m.NumberOfFrames
    fr_in = read(m,n);
    fr_out = data_on_blue_frame(fr_in,n, opt.eeg, [], opt);
    % Safe the frame
    frame = getframe;
    writeVideo(m_out, frame);
    
    pause(0.05);
end

close(m_out);



