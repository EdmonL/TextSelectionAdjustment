static class TextAreaTouchZone extends Zone {

  protected final TextArea textArea;

  TextAreaTouchZone(final TextArea textArea) {
    super(textArea.x, textArea.y, textArea.width, textArea.height);
    this.textArea = textArea;
  }

  @Override public void touchDown(final Touch touch) {
    if (getTouches().length == 1) {
      if (textArea.hasSelection()) {
        textArea.setSelection(0, 0);
      } else {
        final TextPosition tp = textArea.getTextPositionByInnerPoint(textArea.getInnerPointByPoint(touch.x, touch.y));
        textArea.setSelection(tp.offset, tp.offset + tp.toward);
      }
    }
  }

  @Override public void touch() {
  }

  @Override public void draw() {
  }
}

