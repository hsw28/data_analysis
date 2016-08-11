function demoSWWmd(md)

m = md.mdata;
thresh = md.thresh;

dPath=[md.mdata.basePath,'/d',num2str(md.twin(1)),'_',...
    num2str(md.twin(2)),'.mat'];

load(dPath,'r');

tg = m.trode_groups_fn('date',m.today,'segment_style','areas');

[eventsCA1,eventsRSC,eventsCTX] = plotTwoMeans(r,tg,md.areas,thresh);
eventsCA1 = cellfun(@mean, eventsCA1);
eventsRSC = cellfun(@mean, eventsRSC);
eventsCTX = cellfun(@mean, eventsCTX);

if(any(strcmp('run',md.sessions)))

    load(dPath,'d');
    runTimewins = ...
                gh_union_segs( timeArrayToSegments(d.pos_info.out_run_bouts),...
                                timeArrayToSegments(d.pos_info.in_run_bouts));
    pauseTimewins = gh_subtract_segs({md.twin},runTimewins);
    gh_draw_segs(pauseTimewins,'names',{'pauses'},'ys',{[0.01,0.011]});
    disp('CA1:')
    disp( ['run: ', num2str(sum( gh_points_are_in_segs(eventsCA1,runTimewins)))]);
    disp( ['pause: ',num2str(sum(gh_points_are_in_segs(eventsCA1,pauseTimewins)))]);
    disp('RSC:')
    disp( ['run: ', num2str(sum( gh_points_are_in_segs(eventsRSC,runTimewins)))]);
    disp( ['pause: ',num2str(sum(gh_points_are_in_segs(eventsRSC,pauseTimewins)))]);
        disp('CTX:')
    disp( ['run: ', num2str(sum( gh_points_are_in_segs(eventsCTX,runTimewins)))]);
    disp( ['pause: ',num2str(sum(gh_points_are_in_segs(eventsCTX,pauseTimewins)))]);
    hold on;
    gh_plot_cont( contmap(@(x) x*0.01 + 0.01, d.pos_info.lin_vel_cdat));
end
hold off;
end

% TODO - this was a copy-paste. refactor
function c = timeArrayToSegments(a)

assert(size(a,2) == 2);

c = mat2cell(a, ones( size(a,1), 1 ), 2);

end