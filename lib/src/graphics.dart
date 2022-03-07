
double secondOverlayOpacityFromFirstAndResultingOpacityMultiplier(
  double firstOverlayOpacity, double resultingOpacityMultiplier
) => (resultingOpacityMultiplier - 1) * firstOverlayOpacity / (1 - firstOverlayOpacity);

double secondOverlayOpacityFromFirstAndAddend(
  double firstOverlayOpacity, double addend
) => secondOverlayOpacityFromFirstAndResultingOpacityMultiplier(
  firstOverlayOpacity, (firstOverlayOpacity + addend) / firstOverlayOpacity
);