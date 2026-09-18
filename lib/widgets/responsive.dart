enum WidthClass { compact, medium, wide, ultraWide }
WidthClass widthClassFor(double width) {
  if (width < 600) return WidthClass.compact;
  if (width < 1100) return WidthClass.medium;
  if (width < 1600) return WidthClass.wide;
  return WidthClass.ultraWide;
}
