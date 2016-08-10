function f = gh_animate_rpos(r_pos, pos_info, track_info, varargin)

p = inputParser();
p.addParamValue('framerate', 20);
p.addParamValue('time_compress', 0.2);
p.addParamValue('patch_colors',[]);
p.addParamValue('timewin',[r_pos(1).tstart, r_pos(1).tend]);
p.addParamValue('movie_name',[]);
p.addParamValue('place_cells',[]);
p.addParamValue('n_track_seg',100);
p.addParamValue('r_tau',[]);
p.addParamValue('fraction_overlap',0);
p.parse(varargin{:});
opt = p.Results;

n_ts = ceil(  (opt.timewin(2) - opt.timewin(1)) * opt.framerate / opt.time_compress );
ts = linspace( opt.timewin(1), opt.timewin(2), n_ts);

pos_x = interp1( pos_info.timestamp, pos_info.x, ts);
pos_y = interp1( pos_info.timestamp, pos_info.y, ts);

if(isempty(opt.patch_colors))
    opt.patch_colors = reconstruction_to_patch_colors(r_pos,track_info,...
        'timewin', opt.timewin, 'framerate', opt.framerate, ...
        'time_compress', opt.time_compress,'pdf_exponentiator',1);
end

set(gcf,'Renderer', 'zbuffer');
set(gcf,'Position',[10 10 600 600]);
set(gcf,'Color', [0 0 0]);

r = patch(track_info.field_patches.x, ...
    track_info.field_patches.y, ...
    opt.patch_colors(1,:,:));
axis equal;

set(get(r,'Parent'),'Color',[0.05 0.05 0.05]);

hold on;

p = plot(pos_x(1), pos_y(1),'wo');

if(~isempty(opt.movie_name))
    avifilename = opt.movie_name;
    aviobj = avifile(avifilename,'FPS',opt.framerate);
    set(gcf,'DoubleBuffer','on');
    format long;
end

for n = 1:n_ts
    
    set(r,'CData',opt.patch_colors(n,:,:));
    
    set(p, 'XData', pos_x(n));
    set(p, 'YData', pos_y(n));
    title(['Time:', num2str(ts(n))]);
    
    hold off;
    xlim([ 87 275]);
    ylim([ 41 238]);
    
    if(~isempty(opt.movie_name))
        this_frame = getframe(gcf);
        aviobj = addframe(aviobj, this_frame);
    else
        pause(1/opt.framerate);
    end
end

if(not(isempty(opt.movie_name)))
    aviobj = close(aviobj);
end

