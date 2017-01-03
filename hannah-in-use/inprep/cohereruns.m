function fs = cohereruns(lfpone, lfptwo, inputfile, pos, time, lowband, highband, datatype)
%computes coherence from a starttimes or middletimes file, graphs them all together and returns a vector with mean coherence for each run
% datatype 1 = from starttimes file
% datatype 2 = from middletimes file

figure


  if datatype == 1
      bounds = ceil(size(inputfile,2)-1);
  elseif datatype == 2
     bounds = ceil(size(inputfile,2)./4);
  end

  i = 2;
  means = [];
  while i<= size(inputfile,2)
    starttimes = [];
    endtimes = [];
    firstlfp = [];
    secondlfp =[];
    starting = inputfile(1,(i-1));
    ending = inputfile(1,(i));
    starttimes = find(abs(time-starting)<=.0001);
    endtimes = find(abs(time-ending)<=.0001);
    firstlfp = lfpone(starttimes:endtimes);
    secondlfp = lfptwo(starttimes:endtimes);
    if datatype ==1
      subplot(bounds,2, 2*i-3);
      r = cohere(firstlfp, secondlfp, 1:size(firstlfp), lowband, highband);
      subplot(bounds,2, 2*i-2)
      powermap(r, pos, .7)
      means(end+1) = mean(r(1,:));
      i = i+1;
    elseif datatype ==2
      subplot(bounds,2, i/2);
      r = cohere(firstlfp, secondlfp, time(starttimes:endtimes), lowband, highband);
      means(end+1) = mean(r(1,:));
      i = i+2;
    end
  end
fs= means;
