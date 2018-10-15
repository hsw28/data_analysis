function f = markovvel(decodedvel)
%make sure bins match decoding. put in decoded max not full matrix

vbin = [0; 8; 16; 24; 32; 40; 48; 54];

vel = decodedvel(1,:);
markov = zeros(length(vbin), length(vbin));  %first dimension is current position, second dimension is next position
current = 0;
future = 0;
for k = 1:length(decodedvel)-1
  current = 0;
  future = 0;
    j=1;
    while j<=length(vbin) & current==0
        if j==length(vbin) & vel(k)>vbin(end)
          current = j;
        elseif vel(k)>=vbin(j) & vel(k)<vbin(j+1)
          current = j;
        end
        j = j+1;
    end
    j=1;
    while j<=length(vbin) & future==0
        if j==length(vbin) & vel(k+1)>vbin(end)
           future = j;
        elseif vel(k+1)>=vbin(j) & vel(k+1)<vbin(j+1)
           future = j;
        end
        j = j+1;
    end
    markov(current, future) = markov(current, future)+1;
end

f = markov;


figure

h = heatmap(markov);
ylabel('Decoded Vel at Time t')
xlabel('Decoded Vel at Time t+1')
