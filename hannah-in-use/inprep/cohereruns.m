function fs = cohereruns(lfpone, lfptwo, starttimesfile, time, lowband, highband)
%computes coherence from a starttimes file, graphs them all together and returns a vector with mean coherence for each run

figure
i = 2;
means = [];
bounds = ceil(size(starttimesfile,2)./2);
size(starttimesfile,2);
while i<= size(starttimesfile,2)
    starttimes = [];
    endtimes = [];
    firstlfp = [];
    secondlfp =[];
    starting = starttimesfile(2,(i-1));
    ending = starttimesfile(2,(i));
    starttimes = find(abs(time-starting)<=.0001);
    endtimes = find(abs(time-ending)<=.0001);
    firstlfp = lfpone(starttimes:endtimes);
    secondlfp = lfptwo(starttimes:endtimes);
    subplot(bounds,2, i-1);
    r = cohere(firstlfp, secondlfp, 1:size(firstlfp), lowband, highband);
    means(end+1) = mean(r(1,:));
    i = i+1
end

fs= means;
