function rp = triggeredReconstructionMergeDirections(rpOutbound, rpInbound)
% function rp = triggeredReconstructionMergeDirections(rpOut,rpIn)
% Takes two multi-area triggered-reconstruction structures, flips the
% Y axis of one of them, and averages them together

% check inputs
assert(rpOutbound(1).tstart == rpInbound(1).tstart);
assert(rpOutbound(1).tend == rpInbound(1).tend);
assert(all(rpOutbound(1).x_range == rpInbound(1).x_range));
assert(all(rpOutbound(1).x_range == rpInbound(1).x_range));
assert(rpOutbound(1).r_tau == rpInbound(1).r_tau);
assert(rpOutbound(1).fraction_overlap == rpInbound(1).fraction_overlap);

rp = rpOutbound;

for c = 1:numel(rp)
    rp(c).pdf_by_t = rpOutbound(c).pdf_by_t + flipud(rpInbound(c).pdf_by_t)./2;
end