import java.util.LinkedList;
import java.util.List;

static class TextAreaTouchZone extends Zone {

  protected final TextArea textArea;
  private boolean firstTap;

  public TextAreaTouchZone(final TextArea textArea) {
    super(textArea.x, textArea.y, textArea.width, textArea.height);
    this.textArea = textArea;
    firstTap = true;
  }

  public void addTextSelectionListener(final TextSelectionListener newListener) {
    if (newListener == null) {
      return;
    }
    for (final TextSelectionListener l : tsListeners) {
      if  (newListener.equals(l)) {
        break;
      }
    }
    tsListeners.add(newListener);
  }

  public boolean removeTextSelectionListener(final TextSelectionListener newListener) {
    tsListeners.remove(newListener);
  }

  @Override public void touchDown(final Touch touch) {
    if (firstTap) {
      firstTap = false;
      final TextPosition tp = textArea.getTextPositionByInnerPoint(textArea.getInnerPointByPoint(touch.x, touch.y));
      textArea.setSelection(tp.offset - 3, tp.offset + 3);
    }
    isTap = false;
  }

  @Override public void touchMoved(final Touch touch) {
    final Point lp = touch.getLastPoint();
    isTap = isTap && (lp == null || lp.x == touch.x && lp.y == touch.y);
  }

  public void setFirstTap(boolean f){
     firstTap = f; 
  }
  @Override public void touch() {
  }

  @Override public void draw() {
    textArea.draw();
  }

  protected void onShowingSelection(final int start, final int startRow, final int end, final int endRow) {
  }

  protected void onHidingSelection() {
  }

  protected void nofitySelection(final boolean allTouchesUp) {
    if (textArea.hasSelection()) {
      final int selStart = textArea.getSelectionStart();
      final int selEnd = textArea.getSelectionEnd();
      for (final TextSelectionListener l : tsListeners) {
        l.onTextSelection(selStart, selEnd, allTouchesUp);
      }
    }
  }
}

