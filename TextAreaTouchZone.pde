static class TextAreaTouchZone extends Zone {

  protected final TextArea textArea;
  private boolean firstTap;

  TextAreaTouchZone(final TextArea textArea) {
    super(textArea.x, textArea.y, textArea.width, textArea.height);
    this.textArea = textArea;
    firstTap = true;
  }

  @Override public void touchDown(final Touch touch) {
    if (firstTap) {
      firstTap = false;
      final TextPosition tp = textArea.getTextPositionByInnerPoint(textArea.getInnerPointByPoint(touch.x, touch.y));
      textArea.setSelection(tp.offset - 3, tp.offset + 3);
      
    }
  }

  public void setFirstTap(boolean f){
     firstTap = f; 
  }
  @Override public void touch() {
  }

  @Override public void draw() {
  }
}

