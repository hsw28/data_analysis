function f = findripLFP_MUA(unfilteredLFP, timevector_from_LFP, devAboveMean_LFP, posData, clusters, timewin_MUA)
%finds ripples using LFP and MUA

MUArips = findripMUA(timevector_from_LFP, posData, clusters, timewin_MUA);

LFPrips = findripLFP(unfilteredLFP, timevector_from_LFP, devAboveMean_LFP, posData);

for k=1:length(LFPrips)
  [val ind] = min(abs(LFPrips(2,k)-MUArips(1,:)));
  if abs(MUArips(1,ind)-LFPrips(2,k))< (LFPrips(3,k)-LFPrips(1,k))+.02
    starts = LFPrips(1,k);
    peaks = LFPrips(2,k);
    ends = LFPrips(3,k);
  end
end

f = [starts;peaks;ends];
