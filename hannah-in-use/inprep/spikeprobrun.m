function f = spikeprobrun(time, vel, event, cond)
%bin velocity / acc then find spike probability for that vel or accel
%cond for condition - 1 is not abs value, 2 is abs value

if cond ==2
  vel = abs(vel);
end
v = assignvel(time, vel);
v = smooth(v,50);

%ten bins

binsize = (100-min(v))./10;

m = min(v);
% finds velocities that fall within values, then finds what time points
timea = time(find(v <= m+binsize));
timeb = time(find(v > m+binsize & v <= m+binsize.*2));
timec = time(find(v > m+binsize.*2 & v <= m+binsize.*3));
timed = time(find(v > m+binsize.*3 & v <= m+binsize.*4));
timee = time(find(v > m+binsize.*4 & v <= m+binsize.*5));
timef = time(find(v > m+binsize.*5 & v <= m+binsize.*6));
timeg = time(find(v > m+binsize.*6 & v <= m+binsize.*7));
timeh = time(find(v > m+binsize.*7 & v <= m+binsize.*8));
timei = time(find(v > m+binsize.*8 & v <= m+binsize.*9));
timej = time(find(v > m+binsize.*9 & v <= m+binsize.*10));


% now need to find spiking probabilities within those times
% can do this to see when each time overlaps with a spike time, then dividing by total number of times

%finds number of spikes that occur during each speed block and then divides by total times in block

timea = timea';
timeb = timeb';
timec = timec';
timed = timed';
timee = timee';
timef = timef';
timeg = timeg';
timeh = timeh';
timei = timei';
timej = timej';


f = 1;
pa = 0;
pb = 0;
pc = 0;
pd = 0;
pe = 0;
pf = 0;
pg = 0;
ph = 0;
pi = 0;
pj = 0;


while f <= length(event)
    total = pa+pb+pc+pd+pe+pf+pg+ph+pi+pj;
    pa = pa + size(find(abs(timea-event(f))<=.0001),1);
    pb = pb + size(find(abs(timeb-event(f))<=.0001),1);
    pc = pc + size(find(abs(timec-event(f))<=.0001),1);
    pd = pd + size(find(abs(timed-event(f))<=.0001),1);
    pe = pe + size(find(abs(timee-event(f))<=.0001),1);
    pf = pf + size(find(abs(timef-event(f))<=.0001),1);
    pg = pg + size(find(abs(timeg-event(f))<=.0001),1);
    ph = ph + size(find(abs(timeh-event(f))<=.0001),1);
    pi = pi + size(find(abs(timei-event(f))<=.0001),1);
    pj = pj + size(find(abs(timej-event(f))<=.0001),1);
    if (pa+pb+pc+pd+pe+pf+pg+ph+pi+pj)-total < 1
       event(f);
    end
    f= f+1;
end


proba = pa ./ size(timea,1);
probb = pb ./ size(timeb,1);
probc = pc ./ size(timec,1);
probd = pd ./ size(timed,1);
probe = pe ./ size(timee,1);
probf = pf ./ size(timef,1);
probg = pg ./ size(timeg,1);
probh = ph ./ size(timeh,1);
probi = pi ./ size(timei,1);
probj = pj ./ size(timej,1);



figure
norm = (mapminmax([proba, probb, probc, probd, probe, probf, probg, probh, probi, probj],0,1));
bar([(m+binsize.*1), (m+binsize.*2), (m+binsize.*3), (m+binsize.*4), (m+binsize.*5), (m+binsize.*6), (m+binsize.*7), (m+binsize.*8), (m+binsize.*9), (m+binsize.*10)], norm)
%bar([proba, probb, probc, probd, probe, probf, probg, probh, probi, probj])
%line([m+binsize.*1, m+binsize.*2, m+binsize.*3, m+binsize.*4, m+binsize.*5, m+binsize.*6, m+binsize.*7, m+binsize.*8, m+binsize.*9, m+binsize.*10], [proba, probb, probc, probd, probe, probf, probg, probh, probi, probj])
f= ([proba, probb, probc, probd, probe, probf, probg, probh, probi, probj]);
