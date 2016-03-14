class PinchSelectingZone extends Zone {
  
  private final TextArea textArea;

  PinchSelectingZone(final int x, final int y, final int width, final int height, TextArea textArea) {
    super(x, y, width, height);
    this.textArea = textArea;
  }

  void touchMoved(Touch touch) {
  }
}

