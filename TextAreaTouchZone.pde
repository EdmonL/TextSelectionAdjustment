static class TextAreaTouchZone extends Zone {

  protected final TextArea textArea;
  protected boolean isTap;
  protected long tapStartTimeMillis;

  public TextAreaTouchZone(final String name, final TextArea textArea) {
    super(name, textArea.x, textArea.y, textArea.width, textArea.height);
    this.textArea = textArea;
  }

  @Override public void touchDown(final Touch touch) {
    isTap = getNumTouches() == 1;
    if (isTap) {
      tapStartTimeMillis = System.currentTimeMillis();
    }
  }

  @Override public void touchUp(final Touch touch) {
    if (getNumTouches() == 0) {
      if (isTap) {
        if (abs(System.currentTimeMillis() - tapStartTimeMillis) < 500 && textArea.hasSelection()) {
          textArea.setSelection(0, 0);
          textArea.notifyObservers(new TextSelectionEvent(0, 0, 0, 0, false, false));
        } else if (!textArea.hasSelection()) {
          final TextPosition tp = textArea.getTextPositionByInnerPoint(textArea.getInnerPointByPoint(touch.x, touch.y));
          textArea.setSelection(tp.offset, tp.offset + tp.toward);
          textArea.notifyObservers(new TextSelectionEvent(textArea.getSelectionStart(), tp.row, textArea.getSelectionEnd(), tp.row, true, false));
        }
      }
    }
    isTap = false;
  }

  @Override public void touchMoved(final Touch touch) {
    final Point lp = touch.getLastPoint();
    isTap = isTap && (lp == null || lp.x == touch.x && lp.y == touch.y);
  }

  @Override public void touch() {
  }

  @Override public void draw() {
    textArea.draw();
  }
}

