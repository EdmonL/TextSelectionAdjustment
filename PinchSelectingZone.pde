class PinchSelectingZone extends Zone {

  private final TextArea textArea;

  PinchSelectingZone(final int x, final int y, final int width, final int height, TextArea textArea) {
    super(x, y, width, height);
    this.textArea = textArea;
  }

  @Override
  public void touchDown(Touch touch) {
  }

  @Override
  public void touchMoved(Touch touch) {
  }
  
  @Override
  public void touch() {
  }
  
  @Override
  public void draw() {
  }
}

