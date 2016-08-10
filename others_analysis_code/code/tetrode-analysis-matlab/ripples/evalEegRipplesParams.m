function [rips, peaks] = evalEegRipplesParams(rippleEnv, minPeak, baseCutoff, minLength, bridgeWidth, adequateLocalMin, minPeakDist)

[rips,peaks] = eegRipples(rippleEnv, minPeak, baseCutoff, minLength, bridgeWidth, adequateLocalMin, minPeakDist);

gh_draw_segs(rips);
hold on;
gh_plot_cont(rippleEnv);
plot([0,6000],[minPeak,minPeak]);
plot([0,6000],[baseCutoff,baseCutoff]);
plot([0,6000],[adequateLocalMin,adequateLocalMin]);