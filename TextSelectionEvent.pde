static final class TextSelectionEvent {
  final int start, startRow, end, endRow;
  final boolean isInitial, hasTouches;
  
  public TextSelectionEvent(final int start, final int startRow, final int end, final int endRow, final boolean isInitial, final boolean hasTouches) {
    this.start = start;
    this.startRow = startRow;
    this.end = end;
    this.endRow = endRow;
    this.isInitial = isInitial;
    this.hasTouches = hasTouches;
  }
  
  public boolean hasSelection() {
    return start != end;
  }
}
